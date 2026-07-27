using System;
using System.Collections.Generic;

namespace ATSMiniProject.ViewModels.Dashboard
{
    public class DashboardViewModel
    {
        public string DisplayName { get; set; }
        public int TotalJobs { get; set; }
        public int OpenJobs { get; set; }
        public int ExpiringJobs { get; set; }
        public int TotalApplications { get; set; }
        public int NewApplications { get; set; }
        public int InReviewApplications { get; set; }
        public int? NewApplicationStatusId { get; set; }
        public int? InReviewStatusId { get; set; }
        public int TotalInterviews { get; set; }
        public int UpcomingInterviews { get; set; }
        public int TodayInterviews { get; set; }
        public int TotalActionItems { get; set; }

        public IEnumerable<StatusChartItem> ApplicationStatuses { get; set; }
        public IEnumerable<JobChartItem> JobApplications { get; set; }
        public IEnumerable<UpcomingInterviewItem> UpcomingInterviewItems { get; set; }
        public IEnumerable<RecentActivityItem> RecentActivities { get; set; }
    }

    public class StatusChartItem
    {
        public int StatusId { get; set; }
        public string Name { get; set; }
        public int Count { get; set; }
        public int Percent { get; set; }
        public string CssClass { get; set; }
    }

    public class JobChartItem
    {
        public int JobId { get; set; }
        public string Title { get; set; }
        public int Count { get; set; }
        public int Percent { get; set; }
        public bool IsOpen { get; set; }
    }

    public class UpcomingInterviewItem
    {
        public int InterviewId { get; set; }
        public string CandidateName { get; set; }
        public string JobTitle { get; set; }
        public DateTime InterviewDate { get; set; }
        public string Location { get; set; }
    }

    public class RecentActivityItem
    {
        public string Label { get; set; }
        public string Description { get; set; }
        public string ActorName { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
