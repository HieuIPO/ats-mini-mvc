using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web;
using System.Web.Mvc;

namespace ATSMiniProject.ViewModels.Jobs
{
    public class JobSearchViewModel
    {
        public JobSearchViewModel()
        {
            Jobs = new List<JobCardViewModel>();
            Departments = new List<SelectListItem>();
            Locations = new List<SelectListItem>();
            JobTypes = new List<SelectListItem>();
        }

        public string Keyword { get; set; }
        public string Location { get; set; }
        public string JobType { get; set; }
        public int? DepartmentId { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public IList<JobCardViewModel> Jobs { get; set; }
        public IList<SelectListItem> Departments { get; set; }
        public IList<SelectListItem> Locations { get; set; }
        public IList<SelectListItem> JobTypes { get; set; }
    }

    public class JobCardViewModel
    {
        public int JobId { get; set; }
        public string Title { get; set; }
        public string DepartmentName { get; set; }
        public string PositionName { get; set; }
        public string Location { get; set; }
        public string JobType { get; set; }
        public string SalaryRange { get; set; }
        public string Summary { get; set; }
        public DateTime? Deadline { get; set; }
        public bool IsSaved { get; set; }
    }

    public class JobDetailsViewModel : JobCardViewModel
    {
        public string Industry { get; set; }
        public string Description { get; set; }
        public string Requirements { get; set; }
        public bool IsActive { get; set; }
        public bool AlreadyApplied { get; set; }
        public int? ExistingApplicationId { get; set; }
    }

    public class ApplyApplicationViewModel
    {
        public int JobId { get; set; }
        public string JobTitle { get; set; }
        public string DepartmentName { get; set; }
        public DateTime? Deadline { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập họ và tên.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Họ và tên phải từ 2 đến 100 ký tự.")]
        [Display(Name = "Họ và tên")]
        public string CandidateName { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập số điện thoại.")]
        [RegularExpression(@"^(0|\+84)[0-9]{9,10}$", ErrorMessage = "Số điện thoại Việt Nam không đúng định dạng.")]
        [StringLength(20)]
        [Display(Name = "Số điện thoại")]
        public string CandidatePhone { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập email.")]
        [EmailAddress(ErrorMessage = "Email không đúng định dạng.")]
        [StringLength(100)]
        [Display(Name = "Email")]
        public string CandidateEmail { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn CV.")]
        [Display(Name = "CV")]
        public HttpPostedFileBase CvFile { get; set; }

        [Range(typeof(bool), "true", "true", ErrorMessage = "Bạn cần đồng ý với chính sách bảo mật trước khi nộp hồ sơ.")]
        [Display(Name = "Đồng ý với chính sách bảo mật")]
        public bool AcceptPrivacyPolicy { get; set; }
    }
}
