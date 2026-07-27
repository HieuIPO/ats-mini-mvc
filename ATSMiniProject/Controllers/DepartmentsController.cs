using System;
using System.Linq;
using System.Net;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Jobs;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Admin", "HR")]
    public class DepartmentsController : Controller
    {
        private const int PageSize = 12;
        private readonly ATSMiniDBContext db = new ATSMiniDBContext();

        public ActionResult Index(string keyword, int page = 1)
        {
            var query = db.Departments.Where(d => !d.IsDeleted);

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                var trimmed = keyword.Trim();
                query = query.Where(d => d.DepartmentName.Contains(trimmed) || d.Description.Contains(trimmed));
            }

            var totalItems = query.Count();
            var pagination = Pagination.Calculate(page, totalItems, PageSize);
            var items = query
                .OrderByDescending(d => d.IsActive)
                .ThenBy(d => d.DepartmentName)
                .ThenBy(d => d.DepartmentID)
                .Skip(pagination.Offset)
                .Take(pagination.PageSize)
                .Select(d => new DepartmentListItemViewModel
                {
                    DepartmentID = d.DepartmentID,
                    DepartmentName = d.DepartmentName,
                    Description = d.Description,
                    IsActive = d.IsActive
                })
                .ToList();

            return View(new DepartmentListViewModel
            {
                Keyword = keyword,
                Page = pagination.Page,
                TotalPages = pagination.TotalPages,
                TotalItems = pagination.TotalItems,
                FirstItem = pagination.FirstItem,
                LastItem = pagination.LastItem,
                Items = items
            });
        }

        [HttpGet]
        public ActionResult Create()
        {
            return View(new DepartmentFormViewModel { IsActive = true });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(DepartmentFormViewModel model)
        {
            ValidateUniqueName(model.DepartmentName, model.DepartmentID);

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            db.Departments.Add(new Department
            {
                DepartmentName = model.DepartmentName.Trim(),
                Description = Clean(model.Description),
                IsActive = model.IsActive,
                IsDeleted = false,
                CreatedAt = DateTime.Now,
                CreatedByUserID = CurrentUserId()
            });
            db.SaveChanges();
            TempData["Success"] = "Đã thêm phòng ban.";
            return RedirectToAction("Index");
        }

        [HttpGet]
        public ActionResult Edit(int? id)
        {
            if (!id.HasValue)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }

            var department = db.Departments.SingleOrDefault(d => d.DepartmentID == id.Value && !d.IsDeleted);
            if (department == null)
            {
                return HttpNotFound();
            }

            return View(new DepartmentFormViewModel
            {
                DepartmentID = department.DepartmentID,
                DepartmentName = department.DepartmentName,
                Description = department.Description,
                IsActive = department.IsActive
            });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(DepartmentFormViewModel model)
        {
            ValidateUniqueName(model.DepartmentName, model.DepartmentID);

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var department = db.Departments.SingleOrDefault(d => d.DepartmentID == model.DepartmentID && !d.IsDeleted);
            if (department == null)
            {
                return HttpNotFound();
            }

            department.DepartmentName = model.DepartmentName.Trim();
            department.Description = Clean(model.Description);
            department.IsActive = model.IsActive;
            department.UpdatedAt = DateTime.Now;
            department.UpdatedByUserID = CurrentUserId();
            db.SaveChanges();
            TempData["Success"] = "Đã cập nhật phòng ban.";
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            var department = db.Departments.SingleOrDefault(d => d.DepartmentID == id && !d.IsDeleted);
            if (department == null)
            {
                return HttpNotFound();
            }

            if (db.Jobs.Any(j => j.DepartmentID == id && !j.IsDeleted))
            {
                TempData["Error"] = "Không thể xoá phòng ban đang có tin tuyển dụng. Hãy tạm dừng phòng ban nếu cần.";
                return RedirectToAction("Index");
            }

            department.IsDeleted = true;
            department.IsActive = false;
            department.UpdatedAt = DateTime.Now;
            department.UpdatedByUserID = CurrentUserId();
            db.SaveChanges();
            TempData["Success"] = "Đã xoá phòng ban.";
            return RedirectToAction("Index");
        }

        private void ValidateUniqueName(string name, int id)
        {
            if (!string.IsNullOrWhiteSpace(name) && db.Departments.Any(d => !d.IsDeleted && d.DepartmentID != id && d.DepartmentName == name.Trim()))
            {
                ModelState.AddModelError("DepartmentName", "Tên phòng ban đã tồn tại.");
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
