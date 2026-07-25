using System.ComponentModel.DataAnnotations;

namespace ATSMiniProject.ViewModels.Jobs
{
    public class JobPositionFormViewModel
    {
        public int JobPositionID { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập tên vị trí.")]
        [StringLength(100, ErrorMessage = "Tên vị trí không được vượt quá 100 ký tự.")]
        [Display(Name = "Tên vị trí")]
        public string PositionName { get; set; }

        [StringLength(255, ErrorMessage = "Mô tả không được vượt quá 255 ký tự.")]
        [Display(Name = "Mô tả")]
        public string Description { get; set; }

        [Display(Name = "Đang sử dụng")]
        public bool IsActive { get; set; }
    }
}
