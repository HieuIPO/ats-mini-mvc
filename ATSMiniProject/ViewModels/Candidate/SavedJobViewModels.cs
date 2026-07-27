using System;
using System.Collections.Generic;

namespace ATSMiniProject.ViewModels.Candidate
{
    public sealed class SavedJobListViewModel
    {
        public SavedJobListViewModel()
        {
            Jobs = new List<SavedJobItemViewModel>();
        }

        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public IList<SavedJobItemViewModel> Jobs { get; set; }
    }

    public sealed class SavedJobItemViewModel
    {
        public int JobId { get; set; }
        public string Title { get; set; }
        public string DepartmentName { get; set; }
        public string PositionName { get; set; }
        public string Location { get; set; }
        public string JobType { get; set; }
        public string SalaryRange { get; set; }
        public DateTime SavedAt { get; set; }
        public DateTime? Deadline { get; set; }
        public bool IsActive { get; set; }
        public bool IsExpired { get; set; }

        public bool IsOpen
        {
            get { return IsActive && !IsExpired; }
        }
    }
}
