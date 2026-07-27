using System.Collections.Generic;

namespace ATSMiniProject.ViewModels.Jobs
{
    public class DepartmentListViewModel
    {
        public DepartmentListViewModel()
        {
            Items = new List<DepartmentListItemViewModel>();
        }

        public string Keyword { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public int FirstItem { get; set; }
        public int LastItem { get; set; }
        public IList<DepartmentListItemViewModel> Items { get; set; }
    }

    public class DepartmentListItemViewModel
    {
        public int DepartmentID { get; set; }
        public string DepartmentName { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
    }

    public class JobPositionListViewModel
    {
        public JobPositionListViewModel()
        {
            Items = new List<JobPositionListItemViewModel>();
        }

        public string Keyword { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public int FirstItem { get; set; }
        public int LastItem { get; set; }
        public IList<JobPositionListItemViewModel> Items { get; set; }
    }

    public class JobPositionListItemViewModel
    {
        public int JobPositionID { get; set; }
        public string PositionName { get; set; }
        public string Description { get; set; }
        public bool IsActive { get; set; }
    }
}
