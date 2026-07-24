using System;
using System.Collections.Generic;
using ATSMiniProject.ViewModels.Applications;
using ATSMiniProject.ViewModels.Jobs;

namespace ATSMiniProject.ViewModels.Candidate
{
    public class CandidateDashboardViewModel
    {
        public CandidateDashboardViewModel()
        {
            RecentApplications = new List<CandidateApplicationItemViewModel>();
            RecommendedJobs = new List<JobCardViewModel>();
        }

        public string FullName { get; set; }
        public int TotalApplications { get; set; }
        public int ActiveApplications { get; set; }
        public int UpcomingInterviews { get; set; }
        public DateTime? NextInterviewDate { get; set; }
        public bool IsProfileComplete { get; set; }
        public IList<CandidateApplicationItemViewModel> RecentApplications { get; set; }
        public IList<JobCardViewModel> RecommendedJobs { get; set; }
    }
}
