using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Net;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.Services;
using ATSMiniProject.ViewModels.Jobs;
using ApplicationEntity = ATSMiniProject.Models.Application;

namespace ATSMiniProject.Controllers
{
    public class JobsController : Controller
    {
        private const int PageSize = 9;
        private const int AdminPageSize = 12;
        private readonly ATSMiniDBContext db = new ATSMiniDBContext();

        [HttpGet]
        public ActionResult Index(string keyword, string location, string jobType, int? departmentId, int page = 1)
        {
            page = Math.Max(page, 1);
            var today = DateTime.Today;
            var candidateUserId = IsCandidate() ? (int?)GetCurrentUserId() : null;

            var openJobsQuery = db.Jobs
                .AsNoTracking()
                .Where(j => j.IsActive && !j.IsDeleted &&
                            (!j.Deadline.HasValue || j.Deadline.Value >= today));
            var query = openJobsQuery;

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                var value = keyword.Trim();
                query = query.Where(j => j.Title.Contains(value) ||
                                         j.JobPosition.PositionName.Contains(value) ||
                                         (j.Industry != null && j.Industry.Contains(value)));
            }

            if (!string.IsNullOrWhiteSpace(location))
            {
                var value = location.Trim();
                query = query.Where(j => j.Location != null && j.Location.Contains(value));
            }

            if (!string.IsNullOrWhiteSpace(jobType))
            {
                var value = jobType.Trim();
                query = query.Where(j => j.JobType == value);
            }

            if (departmentId.HasValue)
            {
                query = query.Where(j => j.DepartmentID == departmentId.Value);
            }

            var totalItems = query.Count();
            var totalPages = Math.Max(1, (int)Math.Ceiling(totalItems / (double)PageSize));
            page = Math.Min(page, totalPages);

            var jobs = query
                .OrderBy(j => j.Deadline)
                .ThenByDescending(j => j.CreatedAt)
                .Skip((page - 1) * PageSize)
                .Take(PageSize)
                .Select(j => new JobCardViewModel
                {
                    JobId = j.JobID,
                    Title = j.Title,
                    DepartmentName = j.Department.DepartmentName,
                    PositionName = j.JobPosition.PositionName,
                    Location = j.Location,
                    JobType = j.JobType,
                    SalaryRange = j.SalaryRange,
                    Summary = j.Description,
                    Deadline = j.Deadline,
                    IsSaved = candidateUserId.HasValue &&
                              j.SavedJobs.Any(s => s.CandidateUserID == candidateUserId.Value)
                })
                .ToList();
            foreach (var job in jobs)
            {
                job.Summary = RichTextSanitizer.ToPlainText(job.Summary);
            }

            var departmentRows = db.Departments
                .AsNoTracking()
                .Where(d => d.IsActive && !d.IsDeleted)
                .OrderBy(d => d.DepartmentName)
                .Select(d => new
                {
                    d.DepartmentID,
                    d.DepartmentName
                })
                .ToList();
            var departments = departmentRows
                .Select(d => new SelectListItem
                {
                    Value = d.DepartmentID.ToString(),
                    Text = d.DepartmentName,
                    Selected = departmentId.HasValue && d.DepartmentID == departmentId.Value
                })
                .ToList();
            var locations = openJobsQuery
                .Where(j => j.Location != null && j.Location != string.Empty)
                .Select(j => j.Location)
                .Distinct()
                .OrderBy(value => value)
                .ToList()
                .Select(value => new SelectListItem
                {
                    Value = value,
                    Text = value,
                    Selected = string.Equals(value, location, StringComparison.OrdinalIgnoreCase)
                })
                .ToList();
            var jobTypes = openJobsQuery
                .Where(j => j.JobType != null && j.JobType != string.Empty)
                .Select(j => j.JobType)
                .Distinct()
                .OrderBy(value => value)
                .ToList()
                .Select(value => new SelectListItem
                {
                    Value = value,
                    Text = value,
                    Selected = string.Equals(value, jobType, StringComparison.OrdinalIgnoreCase)
                })
                .ToList();

            return View(new JobSearchViewModel
            {
                Keyword = keyword,
                Location = location,
                JobType = jobType,
                DepartmentId = departmentId,
                Page = page,
                TotalPages = totalPages,
                TotalItems = totalItems,
                Jobs = jobs,
                Departments = departments,
                Locations = locations,
                JobTypes = jobTypes
            });
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult AdminIndex(string keyword, int? departmentId, int? jobPositionId, string location, string jobType, string status, string sort, int page = 1)
        {
            var model = BuildJobFilterModel(keyword, departmentId, jobPositionId, location, jobType, status, sort, false, page);
            return View(model);
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult AdminPreview(int? id)
        {
            if (!id.HasValue)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }

            var model = db.Jobs
                .AsNoTracking()
                .Where(j => j.JobID == id.Value && !j.IsDeleted)
                .Select(j => new JobDetailsViewModel
                {
                    JobId = j.JobID,
                    Title = j.Title,
                    DepartmentName = j.Department.DepartmentName,
                    PositionName = j.JobPosition.PositionName,
                    Industry = j.Industry,
                    Location = j.Location,
                    JobType = j.JobType,
                    SalaryRange = j.SalaryRange,
                    Deadline = j.Deadline,
                    Description = j.Description,
                    Requirements = j.Requirements,
                    IsActive = j.IsActive
                })
                .SingleOrDefault();

            if (model == null)
            {
                return HttpNotFound();
            }

            return View(model);
        }

        [HttpGet]
        public ActionResult Openings(string keyword, int? departmentId, string location, string jobType, int page = 1)
        {
            return RedirectToAction("Index", new
            {
                keyword,
                departmentId,
                location,
                jobType,
                page
            });
        }

        [HttpGet]
        public ActionResult Details(int? id)
        {
            if (!id.HasValue)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }

            var today = DateTime.Today;
            var isBackOffice = IsBackOfficeUser();
            var candidateUserId = IsCandidate() ? (int?)GetCurrentUserId() : null;
            var model = db.Jobs
                .AsNoTracking()
                .Where(j => j.JobID == id.Value && !j.IsDeleted &&
                            (isBackOffice || (j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= today))))
                .Select(j => new JobDetailsViewModel
                {
                    JobId = j.JobID,
                    Title = j.Title,
                    DepartmentName = j.Department.DepartmentName,
                    PositionName = j.JobPosition.PositionName,
                    Industry = j.Industry,
                    Location = j.Location,
                    JobType = j.JobType,
                    SalaryRange = j.SalaryRange,
                    Deadline = j.Deadline,
                    Description = j.Description,
                    Requirements = j.Requirements,
                    IsSaved = candidateUserId.HasValue &&
                              j.SavedJobs.Any(s => s.CandidateUserID == candidateUserId.Value)
                })
                .SingleOrDefault();

            if (model == null)
            {
                return HttpNotFound();
            }

            if (IsCandidate())
            {
                var userId = GetCurrentUserId();
                var applicationId = db.Applications
                    .Where(a => a.JobID == id.Value && a.CandidateUserID == userId && !a.IsDeleted)
                    .Select(a => (int?)a.ApplicationID)
                    .FirstOrDefault();
                model.AlreadyApplied = applicationId.HasValue;
                model.ExistingApplicationId = applicationId;
            }

            return View(model);
        }

        [AuthorizeRole("Candidate")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult SaveJob(int jobId, string returnUrl)
        {
            var userId = GetCurrentUserId();
            if (!db.Jobs.Any(j => j.JobID == jobId && !j.IsDeleted))
            {
                return HttpNotFound();
            }

            if (!db.SavedJobs.Any(s => s.CandidateUserID == userId && s.JobID == jobId))
            {
                var savedJob = new SavedJob
                {
                    CandidateUserID = userId,
                    JobID = jobId,
                    SavedAt = DateTime.Now
                };
                db.SavedJobs.Add(savedJob);

                try
                {
                    db.SaveChanges();
                }
                catch (DbUpdateException)
                {
                    db.Entry(savedJob).State = EntityState.Detached;
                    if (!db.SavedJobs.AsNoTracking().Any(s =>
                        s.CandidateUserID == userId && s.JobID == jobId))
                    {
                        throw;
                    }
                }
            }

            if (Request.IsAjaxRequest())
            {
                return Json(new { success = true, saved = true });
            }

            TempData["Success"] = "Đã lưu tin tuyển dụng.";
            return RedirectAfterSavedJobAction(jobId, returnUrl);
        }

        [AuthorizeRole("Candidate")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UnsaveJob(int jobId, string returnUrl)
        {
            var userId = GetCurrentUserId();
            var savedJob = db.SavedJobs.SingleOrDefault(s =>
                s.CandidateUserID == userId && s.JobID == jobId);
            if (savedJob != null)
            {
                db.SavedJobs.Remove(savedJob);
                db.SaveChanges();
            }

            if (Request.IsAjaxRequest())
            {
                return Json(new { success = true, saved = false });
            }

            TempData["Success"] = "Đã bỏ lưu tin tuyển dụng.";
            return RedirectAfterSavedJobAction(jobId, returnUrl);
        }

        [AuthorizeRole("Candidate")]
        [HttpGet]
        public ActionResult Apply(int id)
        {
            var userId = GetCurrentUserId();
            var existingId = db.Applications
                .Where(a => a.JobID == id && a.CandidateUserID == userId && !a.IsDeleted)
                .Select(a => (int?)a.ApplicationID)
                .FirstOrDefault();

            if (existingId.HasValue)
            {
                TempData["Error"] = "Bạn đã nộp hồ sơ cho vị trí này.";
                return RedirectToAction("Status", "Applications");
            }

            var model = BuildApplyModel(id, userId);
            if (model == null)
            {
                return HttpNotFound();
            }

            return View(model);
        }

        [AuthorizeRole("Candidate")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Apply(ApplyApplicationViewModel model)
        {
            var userId = GetCurrentUserId();
            var fileError = CandidateFileValidator.Validate(model.CvFile);
            if (fileError != null)
            {
                ModelState.AddModelError("CvFile", fileError);
            }

            var jobModel = BuildApplyModel(model.JobId, userId);
            if (jobModel == null)
            {
                return HttpNotFound();
            }

            model.JobTitle = jobModel.JobTitle;
            model.DepartmentName = jobModel.DepartmentName;
            model.Deadline = jobModel.Deadline;

            var normalizedEmail = string.IsNullOrWhiteSpace(model.CandidateEmail)
                ? string.Empty
                : model.CandidateEmail.Trim().ToLowerInvariant();

            var isDuplicate = db.Applications.Any(a =>
                a.JobID == model.JobId && !a.IsDeleted &&
                (a.CandidateUserID == userId || a.CandidateEmail == normalizedEmail));
            if (isDuplicate)
            {
                ModelState.AddModelError(string.Empty, "Bạn đã nộp hồ sơ cho vị trí này.");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var initialStatus = db.ApplicationStatuses
                .OrderBy(s => s.DisplayOrder)
                .FirstOrDefault(s => s.StatusName == "Mới nộp") ??
                db.ApplicationStatuses.OrderBy(s => s.DisplayOrder).FirstOrDefault();
            if (initialStatus == null)
            {
                ModelState.AddModelError(string.Empty, "Hệ thống chưa cấu hình trạng thái hồ sơ ban đầu.");
                return View(model);
            }

            var extension = Path.GetExtension(Path.GetFileName(model.CvFile.FileName)).ToLowerInvariant();
            var storedFileName = Guid.NewGuid().ToString("N") + extension;
            var uploadDirectory = Server.MapPath("~/Uploads/CVs");
            var physicalPath = Path.Combine(uploadDirectory, storedFileName);
            var relativePath = "Uploads/CVs/" + storedFileName;

            using (var transaction = db.Database.BeginTransaction())
            {
                try
                {
                    Directory.CreateDirectory(uploadDirectory);

                    var now = DateTime.Now;
                    var application = new ApplicationEntity
                    {
                        JobID = model.JobId,
                        CandidateUserID = userId,
                        CandidateName = model.CandidateName.Trim(),
                        CandidatePhone = model.CandidatePhone.Trim(),
                        CandidateEmail = normalizedEmail,
                        CVFilePath = relativePath,
                        StatusID = initialStatus.StatusID,
                        AppliedDate = now,
                        IsDeleted = false
                    };

                    db.Applications.Add(application);
                    db.SaveChanges();

                    model.CvFile.SaveAs(physicalPath);

                    db.CandidateFiles.Add(new CandidateFile
                    {
                        ApplicationID = application.ApplicationID,
                        OriginalFileName = Path.GetFileName(model.CvFile.FileName),
                        StoredFileName = storedFileName,
                        FilePath = relativePath,
                        FileExtension = extension,
                        FileSizeKB = (model.CvFile.ContentLength + 1023) / 1024,
                        UploadedAt = now,
                        UploadedByUserID = userId,
                        IsDeleted = false
                    });
                    db.ApplicationStatusHistories.Add(new ApplicationStatusHistory
                    {
                        ApplicationID = application.ApplicationID,
                        OldStatusID = null,
                        NewStatusID = initialStatus.StatusID,
                        ChangedByUserID = userId,
                        ChangedAt = now,
                        Note = "Ứng viên nộp hồ sơ."
                    });
                    db.AuditLogs.Add(new AuditLog
                    {
                        UserID = userId,
                        ActionName = "SUBMIT_APPLICATION",
                        TableName = "Applications",
                        RecordID = application.ApplicationID,
                        Description = "Ứng viên nộp hồ sơ cho tin tuyển dụng #" + model.JobId + ".",
                        CreatedAt = now,
                        IpAddress = Request.UserHostAddress
                    });
                    db.SaveChanges();
                    transaction.Commit();

                    try
                    {
                        new NotificationService()
                            .CreateNewApplicationNotification(application.ApplicationID);
                    }
                    catch (Exception notificationException)
                    {
                        Trace.TraceError(
                            "Could not create notification for application {0}: {1}",
                            application.ApplicationID,
                            notificationException);
                    }

                    TempData["Success"] = "Nộp hồ sơ thành công.";
                    return RedirectToAction("Status", "Applications");
                }
                catch (DbUpdateException)
                {
                    transaction.Rollback();
                    DeleteFileIfExists(physicalPath);
                    ModelState.AddModelError(string.Empty, "Hồ sơ đã tồn tại hoặc dữ liệu vừa thay đổi. Vui lòng tải lại trang.");
                }
                catch (IOException)
                {
                    transaction.Rollback();
                    DeleteFileIfExists(physicalPath);
                    ModelState.AddModelError("CvFile", "Không thể lưu CV. Vui lòng thử lại.");
                }
                catch (UnauthorizedAccessException)
                {
                    transaction.Rollback();
                    DeleteFileIfExists(physicalPath);
                    ModelState.AddModelError("CvFile", "Không thể lưu CV. Vui lòng thử lại.");
                }
            }

            return View(model);
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult Create()
        {
            PopulateJobDropdowns();
            return View(new JobFormViewModel { IsActive = true });
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(JobFormViewModel model)
        {
            SanitizeRichTextFields(model);
            ValidateSalaryRange(model);
            ValidateDeadline(model);

            if (!ModelState.IsValid)
            {
                PopulateJobDropdowns(model.DepartmentID, model.JobPositionID);
                return View(model);
            }

            var now = DateTime.Now;
            var job = new Job
            {
                Title = model.Title.Trim(),
                Description = model.Description.Trim(),
                Requirements = model.Requirements.Trim(),
                DepartmentID = model.DepartmentID.Value,
                JobPositionID = model.JobPositionID.Value,
                Industry = Clean(model.Industry),
                SalaryRange = Clean(model.SalaryRange),
                Location = Clean(model.Location),
                JobType = Clean(model.JobType),
                Deadline = model.Deadline,
                IsActive = model.IsActive,
                IsDeleted = false,
                CreatedAt = now,
                CreatedByUserID = CurrentUserId()
            };

            db.Jobs.Add(job);
            db.SaveChanges();
            TempData["Success"] = "Đã tạo tin tuyển dụng mới.";
            return RedirectToAction("AdminIndex");
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult Edit(int? id)
        {
            if (!id.HasValue)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }

            var job = db.Jobs.SingleOrDefault(j => j.JobID == id.Value && !j.IsDeleted);
            if (job == null)
            {
                return HttpNotFound();
            }

            PopulateJobDropdowns(job.DepartmentID, job.JobPositionID);
            return View(ToFormModel(job));
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(JobFormViewModel model)
        {
            SanitizeRichTextFields(model);
            ValidateSalaryRange(model);
            ValidateDeadline(model);

            if (!ModelState.IsValid)
            {
                PopulateJobDropdowns(model.DepartmentID, model.JobPositionID);
                return View(model);
            }

            var job = db.Jobs.SingleOrDefault(j => j.JobID == model.JobID && !j.IsDeleted);
            if (job == null)
            {
                return HttpNotFound();
            }

            job.Title = model.Title.Trim();
            job.Description = model.Description.Trim();
            job.Requirements = model.Requirements.Trim();
            job.DepartmentID = model.DepartmentID.Value;
            job.JobPositionID = model.JobPositionID.Value;
            job.Industry = Clean(model.Industry);
            job.SalaryRange = Clean(model.SalaryRange);
            job.Location = Clean(model.Location);
            job.JobType = Clean(model.JobType);
            job.Deadline = model.Deadline;
            job.IsActive = model.IsActive;
            job.UpdatedAt = DateTime.Now;
            job.UpdatedByUserID = CurrentUserId();

            db.SaveChanges();
            TempData["Success"] = "Đã cập nhật tin tuyển dụng.";
            return RedirectToAction("AdminIndex");
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ToggleStatus(int id)
        {
            var job = db.Jobs.SingleOrDefault(j => j.JobID == id && !j.IsDeleted);
            if (job == null)
            {
                return HttpNotFound();
            }

            job.IsActive = !job.IsActive;
            job.UpdatedAt = DateTime.Now;
            job.UpdatedByUserID = CurrentUserId();
            db.SaveChanges();

            TempData["Success"] = job.IsActive ? "Đã mở lại tin tuyển dụng." : "Đã đóng tin tuyển dụng.";
            return RedirectToAction("AdminIndex");
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            var job = db.Jobs.SingleOrDefault(j => j.JobID == id && !j.IsDeleted);
            if (job == null)
            {
                return HttpNotFound();
            }

            job.IsDeleted = true;
            job.IsActive = false;
            job.UpdatedAt = DateTime.Now;
            job.UpdatedByUserID = CurrentUserId();
            db.SaveChanges();

            TempData["Success"] = "Đã xoá tin tuyển dụng khỏi danh sách quản lý.";
            return RedirectToAction("AdminIndex");
        }

        private ApplyApplicationViewModel BuildApplyModel(int jobId, int userId)
        {
            var today = DateTime.Today;
            var job = db.Jobs
                .AsNoTracking()
                .Where(j => j.JobID == jobId && j.IsActive && !j.IsDeleted &&
                            (!j.Deadline.HasValue || j.Deadline.Value >= today))
                .Select(j => new
                {
                    j.JobID,
                    j.Title,
                    j.Deadline,
                    j.Department.DepartmentName
                })
                .SingleOrDefault();
            var user = db.Users.AsNoTracking().SingleOrDefault(u => u.UserID == userId && u.IsActive);

            if (job == null || user == null)
            {
                return null;
            }

            return new ApplyApplicationViewModel
            {
                JobId = job.JobID,
                JobTitle = job.Title,
                DepartmentName = job.DepartmentName,
                Deadline = job.Deadline,
                CandidateName = user.FullName,
                CandidatePhone = user.Phone,
                CandidateEmail = user.Email
            };
        }

        private JobFilterViewModel BuildJobFilterModel(string keyword, int? departmentId, int? jobPositionId, string location, string jobType, string status, string sort, bool publicOnly, int page)
        {
            var today = DateTime.Today;
            var expiringThrough = today.AddDays(7);
            var baseQuery = db.Jobs.Where(j => !j.IsDeleted);
            var query = baseQuery
                .Include(j => j.Department)
                .Include(j => j.JobPosition)
                .AsQueryable();

            if (publicOnly)
            {
                query = query.Where(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= today));
            }

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                var trimmed = keyword.Trim();
                query = query.Where(j =>
                    j.Title.Contains(trimmed) ||
                    j.Description.Contains(trimmed) ||
                    j.Requirements.Contains(trimmed) ||
                    j.Industry.Contains(trimmed));
            }

            if (departmentId.HasValue)
            {
                query = query.Where(j => j.DepartmentID == departmentId.Value);
            }

            if (jobPositionId.HasValue)
            {
                query = query.Where(j => j.JobPositionID == jobPositionId.Value);
            }

            if (!string.IsNullOrWhiteSpace(location))
            {
                query = query.Where(j => j.Location == location);
            }

            if (!string.IsNullOrWhiteSpace(jobType))
            {
                query = query.Where(j => j.JobType == jobType);
            }

            if (!publicOnly && !string.IsNullOrWhiteSpace(status))
            {
                if (status.Equals("open", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= today));
                }
                else if (status.Equals("expiring", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(j =>
                        j.IsActive &&
                        j.Deadline.HasValue &&
                        j.Deadline.Value >= today &&
                        j.Deadline.Value <= expiringThrough);
                }
                else if (status.Equals("closed", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(j =>
                        !j.IsActive &&
                        (!j.Deadline.HasValue || j.Deadline.Value >= today));
                }
                else if (status.Equals("expired", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(j => j.Deadline.HasValue && j.Deadline.Value < today);
                }
            }

            var filteredJobs = query.Count();
            var pagination = Pagination.Calculate(page, filteredJobs, AdminPageSize);
            if (string.Equals(sort, "applications", StringComparison.OrdinalIgnoreCase))
            {
                query = query
                    .OrderByDescending(j => j.Applications.Count(a => !a.IsDeleted))
                    .ThenBy(j => j.Deadline)
                    .ThenByDescending(j => j.CreatedAt)
                    .ThenBy(j => j.JobID);
            }
            else if (string.Equals(sort, "newest", StringComparison.OrdinalIgnoreCase))
            {
                query = query
                    .OrderByDescending(j => j.CreatedAt)
                    .ThenBy(j => j.Deadline)
                    .ThenBy(j => j.JobID);
            }
            else
            {
                sort = "deadline";
                query = query
                    .OrderByDescending(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= today))
                    .ThenBy(j => j.Deadline.HasValue && j.Deadline.Value < today)
                    .ThenBy(j => j.Deadline)
                    .ThenByDescending(j => j.CreatedAt)
                    .ThenBy(j => j.JobID);
            }

            return new JobFilterViewModel
            {
                Keyword = keyword,
                DepartmentID = departmentId,
                JobPositionID = jobPositionId,
                Location = location,
                JobType = jobType,
                Status = status,
                Sort = sort,
                TotalJobs = baseQuery.Count(),
                OpenJobs = baseQuery.Count(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= today)),
                ExpiringJobs = baseQuery.Count(j =>
                    j.IsActive &&
                    j.Deadline.HasValue &&
                    j.Deadline.Value >= today &&
                    j.Deadline.Value <= expiringThrough),
                ClosedJobs = baseQuery.Count(j =>
                    !j.IsActive &&
                    (!j.Deadline.HasValue || j.Deadline.Value >= today)),
                ExpiredJobs = baseQuery.Count(j => j.Deadline.HasValue && j.Deadline.Value < today),
                FilteredJobs = filteredJobs,
                Page = pagination.Page,
                TotalPages = pagination.TotalPages,
                FirstItem = pagination.FirstItem,
                LastItem = pagination.LastItem,
                Jobs = query
                    .Skip(pagination.Offset)
                    .Take(pagination.PageSize)
                    .Select(j => new AdminJobListItemViewModel
                    {
                        JobID = j.JobID,
                        Title = j.Title,
                        DepartmentName = j.Department == null ? null : j.Department.DepartmentName,
                        PositionName = j.JobPosition == null ? null : j.JobPosition.PositionName,
                        Location = j.Location,
                        JobType = j.JobType,
                        Deadline = j.Deadline,
                        IsActive = j.IsActive,
                        ApplicationCount = j.Applications.Count(a => !a.IsDeleted),
                        CreatedAt = j.CreatedAt
                    })
                    .ToList(),
                Departments = BuildDepartmentItems(departmentId),
                JobPositions = BuildJobPositionItems(jobPositionId),
                Locations = BuildSimpleItems(baseQuery.Select(j => j.Location).Where(v => v != null && v != string.Empty).Distinct().OrderBy(v => v), location),
                JobTypes = BuildSimpleItems(baseQuery.Select(j => j.JobType).Where(v => v != null && v != string.Empty).Distinct().OrderBy(v => v), jobType)
            };
        }

        private void PopulateJobDropdowns(int? departmentId = null, int? jobPositionId = null)
        {
            ViewBag.DepartmentOptions = BuildDepartmentItems(departmentId);
            ViewBag.JobPositionOptions = BuildJobPositionItems(jobPositionId);
        }

        private IEnumerable<SelectListItem> BuildDepartmentItems(int? selectedId)
        {
            return db.Departments
                .Where(d => (!d.IsDeleted && d.IsActive) ||
                            (selectedId.HasValue && d.DepartmentID == selectedId.Value))
                .OrderBy(d => d.DepartmentName)
                .ToList()
                .Select(d => new SelectListItem
                {
                    Value = d.DepartmentID.ToString(),
                    Text = d.IsActive && !d.IsDeleted
                        ? d.DepartmentName
                        : d.DepartmentName + " (dữ liệu hiện tại)",
                    Selected = selectedId.HasValue && d.DepartmentID == selectedId.Value
                });
        }

        private IEnumerable<SelectListItem> BuildJobPositionItems(int? selectedId)
        {
            return db.JobPositions
                .Where(p => (!p.IsDeleted && p.IsActive) ||
                            (selectedId.HasValue && p.JobPositionID == selectedId.Value))
                .OrderBy(p => p.PositionName)
                .ToList()
                .Select(p => new SelectListItem
                {
                    Value = p.JobPositionID.ToString(),
                    Text = p.IsActive && !p.IsDeleted
                        ? p.PositionName
                        : p.PositionName + " (dữ liệu hiện tại)",
                    Selected = selectedId.HasValue && p.JobPositionID == selectedId.Value
                });
        }

        private IEnumerable<SelectListItem> BuildSimpleItems(IEnumerable<string> values, string selectedValue)
        {
            return values.ToList().Select(value => new SelectListItem
            {
                Value = value,
                Text = value,
                Selected = string.Equals(value, selectedValue, StringComparison.OrdinalIgnoreCase)
            });
        }

        private JobFormViewModel ToFormModel(Job job)
        {
            return new JobFormViewModel
            {
                JobID = job.JobID,
                Title = job.Title,
                Description = job.Description,
                Requirements = job.Requirements,
                DepartmentID = job.DepartmentID,
                JobPositionID = job.JobPositionID,
                Industry = job.Industry,
                SalaryRange = job.SalaryRange,
                Location = job.Location,
                JobType = job.JobType,
                Deadline = job.Deadline,
                IsActive = job.IsActive
            };
        }

        private void SanitizeRichTextFields(JobFormViewModel model)
        {
            model.Description = RichTextSanitizer.Sanitize(model.Description);
            model.Requirements = RichTextSanitizer.Sanitize(model.Requirements);
            ModelState.SetModelValue(
                "Description",
                new ValueProviderResult(model.Description, model.Description, System.Globalization.CultureInfo.CurrentCulture));
            ModelState.SetModelValue(
                "Requirements",
                new ValueProviderResult(model.Requirements, model.Requirements, System.Globalization.CultureInfo.CurrentCulture));

            if (!RichTextSanitizer.HasMeaningfulText(model.Description))
            {
                ModelState.AddModelError("Description", "Vui lòng nhập mô tả công việc.");
            }
            else if (RichTextSanitizer.ToPlainText(model.Description).Length > 20000)
            {
                ModelState.AddModelError("Description", "Mô tả công việc không được vượt quá 20.000 ký tự.");
            }

            if (!RichTextSanitizer.HasMeaningfulText(model.Requirements))
            {
                ModelState.AddModelError("Requirements", "Vui lòng nhập yêu cầu ứng viên.");
            }
            else if (RichTextSanitizer.ToPlainText(model.Requirements).Length > 20000)
            {
                ModelState.AddModelError("Requirements", "Yêu cầu ứng viên không được vượt quá 20.000 ký tự.");
            }
        }

        private void ValidateDeadline(JobFormViewModel model)
        {
            if (model.Deadline.HasValue && model.Deadline.Value.Date < DateTime.Today)
            {
                ModelState.AddModelError("Deadline", "Hạn nộp không được nhỏ hơn ngày hiện tại.");
            }
        }

        private void ValidateSalaryRange(JobFormViewModel model)
        {
            string normalized;
            string errorMessage;
            if (!SalaryRangePolicy.TryNormalize(model.SalaryRange, out normalized, out errorMessage))
            {
                ModelState.AddModelError("SalaryRange", errorMessage);
                return;
            }

            model.SalaryRange = normalized;
            ModelState.SetModelValue(
                "SalaryRange",
                new ValueProviderResult(normalized, normalized, System.Globalization.CultureInfo.CurrentCulture));
        }

        private string Clean(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private ActionResult RedirectAfterSavedJobAction(int jobId, string returnUrl)
        {
            if (Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }

            return RedirectToAction("Details", new { id = jobId });
        }

        private int? CurrentUserId()
        {
            return Session[AuthSessionKeys.UserID] as int?;
        }

        private int GetCurrentUserId()
        {
            return Convert.ToInt32(Session[AuthSessionKeys.UserID]);
        }

        private bool IsBackOfficeUser()
        {
            var roleName = Session[AuthSessionKeys.RoleName] as string;
            return string.Equals(roleName, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(roleName, "HR", StringComparison.OrdinalIgnoreCase);
        }

        private bool IsCandidate()
        {
            return string.Equals(
                Session[AuthSessionKeys.RoleName] as string,
                "Candidate",
                StringComparison.OrdinalIgnoreCase);
        }

        private static void DeleteFileIfExists(string physicalPath)
        {
            try
            {
                if (System.IO.File.Exists(physicalPath))
                {
                    System.IO.File.Delete(physicalPath);
                }
            }
            catch (IOException)
            {
                // Best-effort cleanup; the original operation error is more useful to the user.
            }
            catch (UnauthorizedAccessException)
            {
                // Best-effort cleanup; operations can inspect the orphan from audit/logs.
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }

            base.Dispose(disposing);
        }
    }
}
