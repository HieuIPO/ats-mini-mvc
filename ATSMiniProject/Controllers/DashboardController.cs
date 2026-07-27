using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
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
                var tomorrow = today.AddDays(1);
                var expiringThrough = today.AddDays(7);
                var jobs = db.Jobs.Where(j => !j.IsDeleted);
                var applications = db.Applications.Where(a => !a.IsDeleted);
                var interviews = db.Interviews.Where(i => !i.IsDeleted && !i.Application.IsDeleted);
                var totalApplications = applications.Count();

                var statusItems = db.ApplicationStatuses
                    .GroupJoin(applications, s => s.StatusID, a => a.StatusID, (status, appGroup) => new
                    {
                        status.StatusID,
                        status.StatusName,
                        status.DisplayOrder,
                        Count = appGroup.Count()
                    })
                    .OrderBy(x => x.DisplayOrder)
                    .ToList()
                    .Select((x, index) => new StatusChartItem
                    {
                        StatusId = x.StatusID,
                        Name = x.StatusName,
                        Count = x.Count,
                        Percent = totalApplications == 0 ? 0 : Math.Max(8, (int)Math.Round((double)x.Count * 100 / totalApplications)),
                        CssClass = "chart-tone-" + ((index % 5) + 1)
                    })
                    .ToList();

                var newStatus = db.ApplicationStatuses
                    .AsNoTracking()
                    .FirstOrDefault(s => s.StatusName == "Mới nộp");
                var inReviewStatus = db.ApplicationStatuses
                    .AsNoTracking()
                    .FirstOrDefault(s => s.StatusName == "Đang xem xét");
                var newApplications = newStatus == null
                    ? 0
                    : applications.Count(a => a.StatusID == newStatus.StatusID);
                var inReviewApplications = inReviewStatus == null
                    ? 0
                    : applications.Count(a => a.StatusID == inReviewStatus.StatusID);
                var expiringJobs = jobs.Count(j =>
                    j.IsActive &&
                    j.Deadline.HasValue &&
                    j.Deadline.Value >= today &&
                    j.Deadline.Value <= expiringThrough);
                var todayInterviews = interviews.Count(i =>
                    i.InterviewDate >= today &&
                    i.InterviewDate < tomorrow);

                var maxJobApplications = Math.Max(1, applications.GroupBy(a => a.JobID).Select(g => g.Count()).DefaultIfEmpty(0).Max());
                var jobApplications = jobs
                    .GroupJoin(applications, j => j.JobID, a => a.JobID, (job, appGroup) => new
                    {
                        job.JobID,
                        job.Title,
                        job.IsActive,
                        job.Deadline,
                        Count = appGroup.Count()
                    })
                    .OrderByDescending(x => x.Count)
                    .ThenBy(x => x.Deadline)
                    .Take(5)
                    .ToList()
                    .Select(x => new JobChartItem
                    {
                        JobId = x.JobID,
                        Title = x.Title,
                        Count = x.Count,
                        Percent = x.Count == 0 ? 4 : Math.Max(12, (int)Math.Round((double)x.Count * 100 / maxJobApplications)),
                        IsOpen = x.IsActive && (!x.Deadline.HasValue || x.Deadline.Value >= today)
                    })
                    .ToList();

                var businessActions = new[]
                {
                    "SUBMIT_APPLICATION",
                    "UPDATE_APPLICATION_STATUS",
                    "UPDATE_APPLICATION_NOTE",
                    "CREATE_INTERVIEW",
                    "UPDATE_INTERVIEW",
                    "CANCEL_INTERVIEW"
                };
                var recentActivities = db.AuditLogs
                    .AsNoTracking()
                    .Include(log => log.User)
                    .Where(log => businessActions.Contains(log.ActionName))
                    .OrderByDescending(log => log.CreatedAt)
                    .Take(6)
                    .ToList()
                    .Select(log => new RecentActivityItem
                    {
                        Label = GetActivityLabel(log.ActionName),
                        Description = log.Description,
                        ActorName = log.User == null ? "Hệ thống" : log.User.FullName,
                        CreatedAt = log.CreatedAt
                    })
                    .ToList();

                var model = new DashboardViewModel
                {
                    DisplayName = Session[AuthSessionKeys.FullName] as string,
                    TotalJobs = jobs.Count(),
                    OpenJobs = jobs.Count(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= today)),
                    ExpiringJobs = expiringJobs,
                    TotalApplications = totalApplications,
                    NewApplications = newApplications,
                    InReviewApplications = inReviewApplications,
                    NewApplicationStatusId = newStatus == null ? (int?)null : newStatus.StatusID,
                    InReviewStatusId = inReviewStatus == null ? (int?)null : inReviewStatus.StatusID,
                    TotalInterviews = interviews.Count(),
                    UpcomingInterviews = interviews.Count(i => i.InterviewDate >= DateTime.Now),
                    TodayInterviews = todayInterviews,
                    TotalActionItems = newApplications + expiringJobs + todayInterviews,
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
                            InterviewId = i.InterviewID,
                            CandidateName = i.Application == null ? "Ứng viên" : i.Application.CandidateName,
                            JobTitle = i.Application == null || i.Application.Job == null ? "Tin tuyển dụng" : i.Application.Job.Title,
                            InterviewDate = i.InterviewDate,
                            Location = string.IsNullOrWhiteSpace(i.InterviewLocation) ? "Chưa cập nhật" : i.InterviewLocation
                        })
                        .ToList(),
                    RecentActivities = recentActivities
                };

                return View(model);
            }
        }

        private static string GetActivityLabel(string actionName)
        {
            switch (actionName)
            {
                case "SUBMIT_APPLICATION":
                    return "Hồ sơ mới";
                case "UPDATE_APPLICATION_STATUS":
                    return "Đổi trạng thái";
                case "UPDATE_APPLICATION_NOTE":
                    return "Cập nhật ghi chú";
                case "CREATE_INTERVIEW":
                    return "Tạo lịch phỏng vấn";
                case "UPDATE_INTERVIEW":
                    return "Cập nhật phỏng vấn";
                case "CANCEL_INTERVIEW":
                    return "Hủy phỏng vấn";
                default:
                    return "Hoạt động";
            }
        }
    }
}
