using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace ATSMiniProject.ViewModels.Applications
{
    public class AdminApplicationListViewModel
    {
        public AdminApplicationListViewModel()
        {
            Applications = new List<AdminApplicationListItemViewModel>();
            Jobs = new List<SelectListItem>();
            Statuses = new List<SelectListItem>();
        }

        public string Keyword { get; set; }
        public int? JobId { get; set; }
        public int? StatusId { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public IList<AdminApplicationListItemViewModel> Applications { get; set; }
        public IList<SelectListItem> Jobs { get; set; }
        public IList<SelectListItem> Statuses { get; set; }
    }

    public class AdminApplicationListItemViewModel
    {
        public int ApplicationId { get; set; }
        public string CandidateName { get; set; }
        public string CandidateEmail { get; set; }
        public string CandidatePhone { get; set; }
        public string JobTitle { get; set; }
        public string DepartmentName { get; set; }
        public string StatusName { get; set; }
        public bool IsFinal { get; set; }
        public DateTime AppliedDate { get; set; }
        public DateTime? NextInterviewDate { get; set; }
    }

    public class AdminApplicationDetailsViewModel
    {
        public AdminApplicationDetailsViewModel()
        {
            StatusOptions = new List<SelectListItem>();
            StatusHistory = new List<AdminStatusHistoryItemViewModel>();
            Interviews = new List<AdminApplicationInterviewItemViewModel>();
        }

        public int ApplicationId { get; set; }
        public int JobId { get; set; }
        public string JobTitle { get; set; }
        public string DepartmentName { get; set; }
        public string PositionName { get; set; }
        public string CandidateName { get; set; }
        public string CandidateEmail { get; set; }
        public string CandidatePhone { get; set; }
        public string StatusName { get; set; }
        public int StatusId { get; set; }
        public bool IsFinal { get; set; }
        public DateTime AppliedDate { get; set; }
        public string HRNote { get; set; }
        public int? CandidateFileId { get; set; }
        public string CvOriginalFileName { get; set; }
        public IList<SelectListItem> StatusOptions { get; set; }
        public IList<AdminStatusHistoryItemViewModel> StatusHistory { get; set; }
        public IList<AdminApplicationInterviewItemViewModel> Interviews { get; set; }
    }

    public class AdminStatusHistoryItemViewModel
    {
        public string OldStatusName { get; set; }
        public string NewStatusName { get; set; }
        public string ChangedByName { get; set; }
        public DateTime ChangedAt { get; set; }
        public string Note { get; set; }
    }

    public class AdminApplicationInterviewItemViewModel
    {
        public int InterviewId { get; set; }
        public DateTime InterviewDate { get; set; }
        public string Location { get; set; }
        public string InterviewerName { get; set; }
        public string Result { get; set; }
    }

    public class UpdateApplicationStatusViewModel
    {
        [Required]
        public int ApplicationId { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn trạng thái hồ sơ.")]
        [Display(Name = "Trạng thái mới")]
        public int StatusId { get; set; }

        [StringLength(500, ErrorMessage = "Ghi chú trạng thái tối đa 500 ký tự.")]
        [Display(Name = "Ghi chú thay đổi")]
        public string StatusNote { get; set; }

        [StringLength(2000, ErrorMessage = "Ghi chú nội bộ tối đa 2.000 ký tự.")]
        [Display(Name = "Ghi chú nội bộ Nhân sự")]
        public string HRNote { get; set; }
    }
}
