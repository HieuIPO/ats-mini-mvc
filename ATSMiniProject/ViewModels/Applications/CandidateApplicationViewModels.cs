using System;
using System.Collections.Generic;

namespace ATSMiniProject.ViewModels.Applications
{
    public class CandidateApplicationListViewModel
    {
        public CandidateApplicationListViewModel()
        {
            Applications = new List<CandidateApplicationItemViewModel>();
        }

        public IList<CandidateApplicationItemViewModel> Applications { get; set; }
    }

    public class CandidateApplicationItemViewModel
    {
        public int ApplicationId { get; set; }
        public int JobId { get; set; }
        public string JobTitle { get; set; }
        public string DepartmentName { get; set; }
        public string Location { get; set; }
        public string StatusName { get; set; }
        public bool IsFinal { get; set; }
        public DateTime AppliedDate { get; set; }
        public DateTime? NextInterviewDate { get; set; }
    }

    public class CandidateApplicationDetailsViewModel : CandidateApplicationItemViewModel
    {
        public CandidateApplicationDetailsViewModel()
        {
            StatusHistory = new List<CandidateStatusHistoryViewModel>();
            Interviews = new List<CandidateInterviewViewModel>();
        }

        public string PositionName { get; set; }
        public string CandidateName { get; set; }
        public string CandidateEmail { get; set; }
        public string CandidatePhone { get; set; }
        public int? CandidateFileId { get; set; }
        public string CvOriginalFileName { get; set; }
        public IList<CandidateStatusHistoryViewModel> StatusHistory { get; set; }
        public IList<CandidateInterviewViewModel> Interviews { get; set; }
    }

    public class CandidateStatusHistoryViewModel
    {
        public string StatusName { get; set; }
        public DateTime ChangedAt { get; set; }
    }

    public class CandidateInterviewViewModel
    {
        public int InterviewId { get; set; }
        public DateTime InterviewDate { get; set; }
        public string Location { get; set; }
        public string Result { get; set; }
        public bool CanAddToCalendar { get; set; }
    }
}
