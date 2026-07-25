using System;
using System.Data.Entity;
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
            using (var db = new ATSMiniDBContext())
            {
                var today = DateTime.Today;
                var jobs = db.Jobs.Where(j => !j.IsDeleted);
                var applications = db.Applications.Where(a => !a.IsDeleted);
                var interviews = db.Interviews.Where(i => !i.IsDeleted);
                var totalApplications = applications.Count();

                var statusItems = db.ApplicationStatuses
                    .GroupJoin(applications, s => s.StatusID, a => a.StatusID, (status, appGroup) => new
                    {
                        status.StatusName,
                        Count = appGroup.Count()
                    })
                    .OrderByDescending(x => x.Count)
                    .ToList()
                    .Select((x, index) => new StatusChartItem
                    {
                        Name = x.StatusName,
                        Count = x.Count,
                        Percent = totalApplications == 0 ? 0 : Math.Max(8, (int)Math.Round((double)x.Count * 100 / totalApplications)),
                        CssClass = "chart-tone-" + ((index % 5) + 1)
                    })
                    .ToList();

                var maxJobApplications = Math.Max(1, applications.GroupBy(a => a.JobID).Select(g => g.Count()).DefaultIfEmpty(0).Max());
                var jobApplications = jobs
                    .GroupJoin(applications, j => j.JobID, a => a.JobID, (job, appGroup) => new
                    {
                        job.Title,
                        Count = appGroup.Count()
                    })
                    .OrderByDescending(x => x.Count)
                    .Take(5)
                    .ToList()
                    .Select(x => new JobChartItem
                    {
                        Title = x.Title,
                        Count = x.Count,
                        Percent = x.Count == 0 ? 4 : Math.Max(12, (int)Math.Round((double)x.Count * 100 / maxJobApplications))
                    })
                    .ToList();

                var model = new DashboardViewModel
                {
                    TotalJobs = jobs.Count(),
                    OpenJobs = jobs.Count(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= today)),
                    ClosedJobs = jobs.Count(j => !j.IsActive || (j.Deadline.HasValue && j.Deadline.Value < today)),
                    ExpiringJobs = jobs.Count(j => j.IsActive && j.Deadline.HasValue && j.Deadline.Value >= today && DbFunctions.DiffDays(today, j.Deadline.Value) <= 7),
                    TotalApplications = totalApplications,
                    TotalInterviews = interviews.Count(),
                    UpcomingInterviews = interviews.Count(i => i.InterviewDate >= DateTime.Now),
                    ApplicationStatuses = statusItems,
                    JobApplications = jobApplications,
                    UpcomingInterviewItems = interviews
                        .Include(i => i.Application)
                        .Include(i => i.Application.Job)
                        .Where(i => i.InterviewDate >= DateTime.Now)
                        .OrderBy(i => i.InterviewDate)
                        .Take(4)
                        .ToList()
                        .Select(i => new UpcomingInterviewItem
                        {
                            CandidateName = i.Application == null ? "Ứng viên" : i.Application.CandidateName,
                            JobTitle = i.Application == null || i.Application.Job == null ? "Tin tuyển dụng" : i.Application.Job.Title,
                            InterviewTime = i.InterviewDate.ToString("dd/MM/yyyy HH:mm"),
                            Location = string.IsNullOrWhiteSpace(i.InterviewLocation) ? "Chưa cập nhật" : i.InterviewLocation
                        })
                        .ToList()
                };

                return View(model);
            }
        }
    }
}
