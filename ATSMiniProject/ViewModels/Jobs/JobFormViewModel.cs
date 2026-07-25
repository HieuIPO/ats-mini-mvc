using System;
using System.ComponentModel.DataAnnotations;

namespace ATSMiniProject.ViewModels.Jobs
{
    public class JobFormViewModel
    {
        public int JobID { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập tiêu đề tin tuyển dụng.")]
        [StringLength(150, ErrorMessage = "Tiêu đề không được vượt quá 150 ký tự.")]
        [Display(Name = "Tiêu đề")]
        public string Title { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập mô tả công việc.")]
        [Display(Name = "Mô tả công việc")]
        public string Description { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập yêu cầu ứng viên.")]
        [Display(Name = "Yêu cầu ứng viên")]
        public string Requirements { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn phòng ban.")]
        [Display(Name = "Phòng ban")]
        public int? DepartmentID { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn vị trí tuyển dụng.")]
        [Display(Name = "Vị trí")]
        public int? JobPositionID { get; set; }

        [StringLength(100)]
        [Display(Name = "Lĩnh vực")]
        public string Industry { get; set; }

        [StringLength(100)]
        [Display(Name = "Mức lương")]
        public string SalaryRange { get; set; }

        [StringLength(150)]
        [Display(Name = "Địa điểm")]
        public string Location { get; set; }

        [StringLength(50)]
        [Display(Name = "Loại công việc")]
        public string JobType { get; set; }

        [DataType(DataType.Date)]
        [Display(Name = "Hạn nộp")]
        public DateTime? Deadline { get; set; }

        [Display(Name = "Đang mở tuyển")]
        public bool IsActive { get; set; }
    }
}
