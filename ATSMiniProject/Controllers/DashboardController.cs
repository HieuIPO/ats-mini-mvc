using System;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Dashboard;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Admin", "HR")]
    public class DashboardController : Controller
    {
        public ActionResult Index()
        {
            var now = DateTime.Now;
            var today = DateTime.Today;

            using (var db = new ATSMiniDBContext())
            {
                return View(new DashboardViewModel
                {
                    ActiveJobs = db.Jobs.Count(j => j.IsActive && !j.IsDeleted &&
                        (!j.Deadline.HasValue || j.Deadline.Value >= today)),
                    TotalApplications = db.Applications.Count(a => !a.IsDeleted),
                    UnderReviewApplications = db.Applications.Count(a =>
                        !a.IsDeleted && a.ApplicationStatus.StatusName == "Đang xem xét"),
                    UpcomingInterviews = db.Interviews.Count(i => !i.IsDeleted && i.InterviewDate >= now)
                });
            }
        }
    }
}
