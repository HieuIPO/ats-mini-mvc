using System.Collections.Generic;
using ATSMiniProject.ViewModels.Jobs;

namespace ATSMiniProject.ViewModels.Home
{
    public class HomeIndexViewModel
    {
        public HomeIndexViewModel()
        {
            FeaturedJobs = new List<JobCardViewModel>();
        }

        public int ActiveJobs { get; set; }
        public int ActiveDepartments { get; set; }
        public int JobLocations { get; set; }
        public IList<JobCardViewModel> FeaturedJobs { get; set; }
    }
}
