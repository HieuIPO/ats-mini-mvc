using System;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Home;

namespace ATSMiniProject.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            var today = DateTime.Today;

            using (var db = new ATSMiniDBContext())
            {
                var activeJobs = db.Jobs.Where(j => j.IsActive && !j.IsDeleted &&
                    (!j.Deadline.HasValue || j.Deadline.Value >= today));

                return View(new HomeIndexViewModel
                {
                    ActiveJobs = activeJobs.Count(),
                    ActiveDepartments = db.Departments.Count(d => d.IsActive && !d.IsDeleted),
                    JobLocations = activeJobs
                        .Where(j => j.Location != null && j.Location != string.Empty)
                        .Select(j => j.Location)
                        .Distinct()
                        .Count(),
                    FeaturedJobs = activeJobs
                        .OrderBy(j => j.Deadline)
                        .ThenByDescending(j => j.CreatedAt)
                        .Take(3)
                        .Select(j => new ViewModels.Jobs.JobCardViewModel
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
                        .ToList()
                });
            }
        }
    }
}
