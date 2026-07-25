using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Jobs;

namespace ATSMiniProject.Controllers
{
    public class JobsController : Controller
    {
        private readonly ATSMiniDBContext db = new ATSMiniDBContext();

        [HttpGet]
        public ActionResult Index(string keyword, int? departmentId, int? jobPositionId, string location, string jobType, string status)
        {
            var isBackOffice = IsBackOfficeUser();
            var model = BuildJobFilterModel(keyword, departmentId, jobPositionId, location, jobType, status, !isBackOffice);
            return View(isBackOffice ? "AdminIndex" : "Index", model);
        }

        [HttpGet]
        public ActionResult Openings(string keyword, int? departmentId, int? jobPositionId, string location, string jobType)
        {
            var model = BuildJobFilterModel(keyword, departmentId, jobPositionId, location, jobType, "open", true);
            return View("Index", model);
        }

        [HttpGet]
        public ActionResult Details(int? id)
        {
            if (!id.HasValue)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }

            var job = db.Jobs
                .Include(j => j.Department)
                .Include(j => j.JobPosition)
                .SingleOrDefault(j => j.JobID == id.Value && !j.IsDeleted);

            if (job == null)
            {
                return HttpNotFound();
            }

            return View(job);
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
            return RedirectToAction("Index");
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
            return RedirectToAction("Index");
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
            return RedirectToAction("Index");
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
            return RedirectToAction("Index");
        }

        private JobFilterViewModel BuildJobFilterModel(string keyword, int? departmentId, int? jobPositionId, string location, string jobType, string status, bool publicOnly)
        {
            var baseQuery = db.Jobs.Where(j => !j.IsDeleted);
            var query = baseQuery
                .Include(j => j.Department)
                .Include(j => j.JobPosition)
                .AsQueryable();

            if (publicOnly)
            {
                query = query.Where(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= DateTime.Today));
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
                    query = query.Where(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= DateTime.Today));
                }
                else if (status.Equals("closed", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(j => !j.IsActive);
                }
                else if (status.Equals("expired", StringComparison.OrdinalIgnoreCase))
                {
                    query = query.Where(j => j.Deadline.HasValue && j.Deadline.Value < DateTime.Today);
                }
            }

            return new JobFilterViewModel
            {
                Keyword = keyword,
                DepartmentID = departmentId,
                JobPositionID = jobPositionId,
                Location = location,
                JobType = jobType,
                Status = status,
                TotalJobs = baseQuery.Count(),
                OpenJobs = baseQuery.Count(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= DateTime.Today)),
                ClosedJobs = baseQuery.Count(j => !j.IsActive || (j.Deadline.HasValue && j.Deadline.Value < DateTime.Today)),
                Jobs = query.OrderByDescending(j => j.IsActive)
                    .ThenBy(j => j.Deadline.HasValue && j.Deadline.Value < DateTime.Today)
                    .ThenBy(j => j.Deadline)
                    .ThenByDescending(j => j.CreatedAt)
                    .ToList(),
                Departments = BuildDepartmentItems(departmentId),
                JobPositions = BuildJobPositionItems(jobPositionId),
                Locations = BuildSimpleItems(baseQuery.Select(j => j.Location).Where(v => v != null && v != string.Empty).Distinct().OrderBy(v => v), location),
                JobTypes = BuildSimpleItems(baseQuery.Select(j => j.JobType).Where(v => v != null && v != string.Empty).Distinct().OrderBy(v => v), jobType)
            };
        }

        private void PopulateJobDropdowns(int? departmentId = null, int? jobPositionId = null)
        {
            ViewBag.DepartmentID = BuildDepartmentItems(departmentId);
            ViewBag.JobPositionID = BuildJobPositionItems(jobPositionId);
        }

        private IEnumerable<SelectListItem> BuildDepartmentItems(int? selectedId)
        {
            return db.Departments
                .Where(d => !d.IsDeleted && d.IsActive)
                .OrderBy(d => d.DepartmentName)
                .ToList()
                .Select(d => new SelectListItem
                {
                    Value = d.DepartmentID.ToString(),
                    Text = d.DepartmentName,
                    Selected = selectedId.HasValue && d.DepartmentID == selectedId.Value
                });
        }

        private IEnumerable<SelectListItem> BuildJobPositionItems(int? selectedId)
        {
            return db.JobPositions
                .Where(p => !p.IsDeleted && p.IsActive)
                .OrderBy(p => p.PositionName)
                .ToList()
                .Select(p => new SelectListItem
                {
                    Value = p.JobPositionID.ToString(),
                    Text = p.PositionName,
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

        private void ValidateDeadline(JobFormViewModel model)
        {
            if (model.Deadline.HasValue && model.Deadline.Value.Date < DateTime.Today)
            {
                ModelState.AddModelError("Deadline", "Hạn nộp không được nhỏ hơn ngày hiện tại.");
            }
        }

        private string Clean(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private int? CurrentUserId()
        {
            return Session[AuthSessionKeys.UserID] as int?;
        }

        private bool IsBackOfficeUser()
        {
            var roleName = Session[AuthSessionKeys.RoleName] as string;
            return string.Equals(roleName, "Admin", StringComparison.OrdinalIgnoreCase)
                || string.Equals(roleName, "HR", StringComparison.OrdinalIgnoreCase);
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
