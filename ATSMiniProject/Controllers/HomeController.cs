using System;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Jobs;

namespace ATSMiniProject.Controllers
{
    public class HomeController : Controller
    {
        private readonly ATSMiniDBContext db = new ATSMiniDBContext();

        public ActionResult Index()
        {
            var today = DateTime.Today;
            var jobs = db.Jobs
                .AsNoTracking()
                .Where(j => j.IsActive && !j.IsDeleted &&
                            (!j.Deadline.HasValue || j.Deadline.Value >= today))
                .OrderBy(j => j.Deadline)
                .ThenByDescending(j => j.CreatedAt)
                .Take(3)
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

            return View(jobs);
        }

        public ActionResult About()
        {
            return View();
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
