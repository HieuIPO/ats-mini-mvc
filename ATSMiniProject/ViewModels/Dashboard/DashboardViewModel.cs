using System.Collections.Generic;

namespace ATSMiniProject.ViewModels.Dashboard
{
    public class DashboardViewModel
    {
        public int TotalJobs { get; set; }
        public int OpenJobs { get; set; }
        public int ClosedJobs { get; set; }
        public int ExpiringJobs { get; set; }
        public int TotalApplications { get; set; }
        public int TotalInterviews { get; set; }
        public int UpcomingInterviews { get; set; }

        public IEnumerable<StatusChartItem> ApplicationStatuses { get; set; }
        public IEnumerable<JobChartItem> JobApplications { get; set; }
        public IEnumerable<UpcomingInterviewItem> UpcomingInterviewItems { get; set; }
    }

    public class StatusChartItem
    {
        public string Name { get; set; }
        public int Count { get; set; }
        public int Percent { get; set; }
        public string CssClass { get; set; }
    }

    public class JobChartItem
    {
        public string Title { get; set; }
        public int Count { get; set; }
        public int Percent { get; set; }
    }

    public class UpcomingInterviewItem
    {
        public string CandidateName { get; set; }
        public string JobTitle { get; set; }
        public string InterviewTime { get; set; }
        public string Location { get; set; }
    }
}
