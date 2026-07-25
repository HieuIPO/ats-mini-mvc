using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Jobs;
using ApplicationEntity = ATSMiniProject.Models.Application;

namespace ATSMiniProject.Controllers
{
    public class JobsController : Controller
    {
        private const int PageSize = 9;

        [HttpGet]
        public ActionResult Index(string keyword, string location, string jobType, int? departmentId, int page = 1)
        {
            page = Math.Max(page, 1);
            var today = DateTime.Today;

            using (var db = new ATSMiniDBContext())
            {
                var query = db.Jobs
                    .AsNoTracking()
                    .Where(j => j.IsActive && !j.IsDeleted &&
                                (!j.Deadline.HasValue || j.Deadline.Value >= today));

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
                        Deadline = j.Deadline
                    })
                    .ToList();

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
                    Departments = departments
                });
            }
        }

        [HttpGet]
        public ActionResult Details(int id)
        {
            var today = DateTime.Today;

            using (var db = new ATSMiniDBContext())
            {
                var model = db.Jobs
                    .AsNoTracking()
                    .Where(j => j.JobID == id && j.IsActive && !j.IsDeleted &&
                                (!j.Deadline.HasValue || j.Deadline.Value >= today))
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
                        Requirements = j.Requirements
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
                        .Where(a => a.JobID == id && a.CandidateUserID == userId && !a.IsDeleted)
                        .Select(a => (int?)a.ApplicationID)
                        .FirstOrDefault();
                    model.AlreadyApplied = applicationId.HasValue;
                    model.ExistingApplicationId = applicationId;
                }

                return View(model);
            }
        }

        [AuthorizeRole("Candidate")]
        [HttpGet]
        public ActionResult Apply(int id)
        {
            var userId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            {
                var existingId = db.Applications
                    .Where(a => a.JobID == id && a.CandidateUserID == userId && !a.IsDeleted)
                    .Select(a => (int?)a.ApplicationID)
                    .FirstOrDefault();

                if (existingId.HasValue)
                {
                    TempData["Error"] = "Bạn đã nộp hồ sơ cho vị trí này.";
                    return RedirectToAction("Details", "Applications", new { id = existingId.Value });
                }

                var model = BuildApplyModel(db, id, userId);
                if (model == null)
                {
                    return HttpNotFound();
                }

                return View(model);
            }
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

            using (var db = new ATSMiniDBContext())
            {
                var jobModel = BuildApplyModel(db, model.JobId, userId);
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

                        var candidateFile = new CandidateFile
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
                        };
                        db.CandidateFiles.Add(candidateFile);
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

                        TempData["Success"] = "Nộp hồ sơ thành công.";
                        return RedirectToAction("Details", "Applications", new { id = application.ApplicationID });
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
        }

        private ApplyApplicationViewModel BuildApplyModel(ATSMiniDBContext db, int jobId, int userId)
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

        private bool IsCandidate()
        {
            return string.Equals(
                Session[AuthSessionKeys.RoleName] as string,
                "Candidate",
                StringComparison.OrdinalIgnoreCase);
        }

        private int GetCurrentUserId()
        {
            return Convert.ToInt32(Session[AuthSessionKeys.UserID]);
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
    }
}
