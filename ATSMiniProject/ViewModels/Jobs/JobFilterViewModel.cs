using System;
using System.Collections.Generic;
using System.Web.Mvc;

namespace ATSMiniProject.ViewModels.Jobs
{
    public class JobFilterViewModel
    {
        public string Keyword { get; set; }
        public int? DepartmentID { get; set; }
        public int? JobPositionID { get; set; }
        public string Location { get; set; }
        public string JobType { get; set; }
        public string Status { get; set; }
        public string Sort { get; set; }

        public int TotalJobs { get; set; }
        public int OpenJobs { get; set; }
        public int ExpiringJobs { get; set; }
        public int ClosedJobs { get; set; }
        public int ExpiredJobs { get; set; }
        public int FilteredJobs { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int FirstItem { get; set; }
        public int LastItem { get; set; }

        public IEnumerable<AdminJobListItemViewModel> Jobs { get; set; }
        public IEnumerable<SelectListItem> Departments { get; set; }
        public IEnumerable<SelectListItem> JobPositions { get; set; }
        public IEnumerable<SelectListItem> Locations { get; set; }
        public IEnumerable<SelectListItem> JobTypes { get; set; }
    }

    public class AdminJobListItemViewModel
    {
        public int JobID { get; set; }
        public string Title { get; set; }
        public string DepartmentName { get; set; }
        public string PositionName { get; set; }
        public string Location { get; set; }
        public string JobType { get; set; }
        public DateTime? Deadline { get; set; }
        public bool IsActive { get; set; }
        public int ApplicationCount { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
