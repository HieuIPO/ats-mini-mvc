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
    public class JobPositionsController : Controller
    {
        private readonly ATSMiniDBContext db = new ATSMiniDBContext();

        public ActionResult Index(string keyword)
        {
            var query = db.JobPositions.Where(p => !p.IsDeleted);

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                var trimmed = keyword.Trim();
                query = query.Where(p => p.PositionName.Contains(trimmed) || p.Description.Contains(trimmed));
            }

            ViewBag.Keyword = keyword;
            return View(query.OrderByDescending(p => p.IsActive).ThenBy(p => p.PositionName).ToList());
        }

        [HttpGet]
        public ActionResult Create()
        {
            return View(new JobPositionFormViewModel { IsActive = true });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(JobPositionFormViewModel model)
        {
            ValidateUniqueName(model.PositionName, model.JobPositionID);

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            db.JobPositions.Add(new JobPosition
            {
                PositionName = model.PositionName.Trim(),
                Description = Clean(model.Description),
                IsActive = model.IsActive,
                IsDeleted = false,
                CreatedAt = DateTime.Now,
                CreatedByUserID = CurrentUserId()
            });
            db.SaveChanges();
            TempData["Success"] = "Đã thêm vị trí tuyển dụng.";
            return RedirectToAction("Index");
        }

        [HttpGet]
        public ActionResult Edit(int? id)
        {
            if (!id.HasValue)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }

            var position = db.JobPositions.SingleOrDefault(p => p.JobPositionID == id.Value && !p.IsDeleted);
            if (position == null)
            {
                return HttpNotFound();
            }

            return View(new JobPositionFormViewModel
            {
                JobPositionID = position.JobPositionID,
                PositionName = position.PositionName,
                Description = position.Description,
                IsActive = position.IsActive
            });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(JobPositionFormViewModel model)
        {
            ValidateUniqueName(model.PositionName, model.JobPositionID);

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var position = db.JobPositions.SingleOrDefault(p => p.JobPositionID == model.JobPositionID && !p.IsDeleted);
            if (position == null)
            {
                return HttpNotFound();
            }

            position.PositionName = model.PositionName.Trim();
            position.Description = Clean(model.Description);
            position.IsActive = model.IsActive;
            position.UpdatedAt = DateTime.Now;
            position.UpdatedByUserID = CurrentUserId();
            db.SaveChanges();
            TempData["Success"] = "Đã cập nhật vị trí tuyển dụng.";
            return RedirectToAction("Index");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Delete(int id)
        {
            var position = db.JobPositions.SingleOrDefault(p => p.JobPositionID == id && !p.IsDeleted);
            if (position == null)
            {
                return HttpNotFound();
            }

            if (db.Jobs.Any(j => j.JobPositionID == id && !j.IsDeleted))
            {
                TempData["Error"] = "Không thể xoá vị trí đang có tin tuyển dụng. Hãy tạm dừng vị trí nếu cần.";
                return RedirectToAction("Index");
            }

            position.IsDeleted = true;
            position.IsActive = false;
            position.UpdatedAt = DateTime.Now;
            position.UpdatedByUserID = CurrentUserId();
            db.SaveChanges();
            TempData["Success"] = "Đã xoá vị trí tuyển dụng.";
            return RedirectToAction("Index");
        }

        private void ValidateUniqueName(string name, int id)
        {
            if (!string.IsNullOrWhiteSpace(name) && db.JobPositions.Any(p => !p.IsDeleted && p.JobPositionID != id && p.PositionName == name.Trim()))
            {
                ModelState.AddModelError("PositionName", "Tên vị trí đã tồn tại.");
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
