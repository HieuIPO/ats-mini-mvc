using System.ComponentModel.DataAnnotations;

namespace ATSMiniProject.ViewModels.Jobs
{
    public class DepartmentFormViewModel
    {
        public int DepartmentID { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập tên phòng ban.")]
        [StringLength(100, ErrorMessage = "Tên phòng ban không được vượt quá 100 ký tự.")]
        [Display(Name = "Tên phòng ban")]
        public string DepartmentName { get; set; }

        [StringLength(255, ErrorMessage = "Mô tả không được vượt quá 255 ký tự.")]
        [Display(Name = "Mô tả")]
        public string Description { get; set; }

        [Display(Name = "Đang sử dụng")]
        public bool IsActive { get; set; }
    }
}
