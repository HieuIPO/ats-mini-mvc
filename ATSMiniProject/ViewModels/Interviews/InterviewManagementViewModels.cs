using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace ATSMiniProject.ViewModels.Interviews
{
    public class InterviewListViewModel
    {
        public InterviewListViewModel()
        {
            Interviews = new List<InterviewListItemViewModel>();
            ResultOptions = new List<SelectListItem>();
        }

        public string Keyword { get; set; }
        public string Result { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public IList<InterviewListItemViewModel> Interviews { get; set; }
        public IList<SelectListItem> ResultOptions { get; set; }
    }

    public class InterviewListItemViewModel
    {
        public int InterviewId { get; set; }
        public int ApplicationId { get; set; }
        public string CandidateName { get; set; }
        public string JobTitle { get; set; }
        public DateTime InterviewDate { get; set; }
        public string Location { get; set; }
        public string InterviewerName { get; set; }
        public string Result { get; set; }
        public bool IsUpcoming { get; set; }
    }

    public class InterviewEditViewModel
    {
        public InterviewEditViewModel()
        {
            ApplicationOptions = new List<SelectListItem>();
            InterviewerOptions = new List<SelectListItem>();
            ResultOptions = new List<SelectListItem>();
        }

        public int? InterviewId { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn hồ sơ ứng viên.")]
        [Display(Name = "Hồ sơ ứng viên")]
        public int ApplicationId { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn thời gian phỏng vấn.")]
        [Display(Name = "Thời gian phỏng vấn")]
        public DateTime InterviewDate { get; set; }

        [StringLength(150, ErrorMessage = "Địa điểm tối đa 150 ký tự.")]
        [Display(Name = "Địa điểm hoặc đường dẫn họp")]
        public string InterviewLocation { get; set; }

        [Display(Name = "Người phỏng vấn")]
        public int? InterviewerUserId { get; set; }

        [StringLength(2000, ErrorMessage = "Ghi chú tối đa 2.000 ký tự.")]
        [Display(Name = "Nội dung cần lưu ý")]
        public string Note { get; set; }

        [StringLength(100, ErrorMessage = "Kết quả tối đa 100 ký tự.")]
        [Display(Name = "Kết quả")]
        public string Result { get; set; }

        public string CandidateName { get; set; }
        public string JobTitle { get; set; }
        public IList<SelectListItem> ApplicationOptions { get; set; }
        public IList<SelectListItem> InterviewerOptions { get; set; }
        public IList<SelectListItem> ResultOptions { get; set; }
        public bool IsEdit { get { return InterviewId.HasValue; } }
    }
}
