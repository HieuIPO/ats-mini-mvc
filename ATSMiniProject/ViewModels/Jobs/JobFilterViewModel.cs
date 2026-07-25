using System.Collections.Generic;
using System.Web.Mvc;
using ATSMiniProject.Models;

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

        public int TotalJobs { get; set; }
        public int OpenJobs { get; set; }
        public int ClosedJobs { get; set; }

        public IEnumerable<Job> Jobs { get; set; }
        public IEnumerable<SelectListItem> Departments { get; set; }
        public IEnumerable<SelectListItem> JobPositions { get; set; }
        public IEnumerable<SelectListItem> Locations { get; set; }
        public IEnumerable<SelectListItem> JobTypes { get; set; }
    }
}
