using System.ComponentModel.DataAnnotations;

namespace ATSMiniProject.ViewModels.Candidate
{
    public class CandidateProfilePageViewModel
    {
        public CandidateProfilePageViewModel()
        {
            Profile = new CandidateProfileViewModel();
            Password = new CandidateChangePasswordViewModel();
        }

        public CandidateProfileViewModel Profile { get; set; }
        public CandidateChangePasswordViewModel Password { get; set; }
        public string AvatarUrl { get; set; }
        public bool HasAvatar { get; set; }
    }

    public class CandidateProfileViewModel
    {
        public string Username { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập họ và tên.")]
        [StringLength(100, MinimumLength = 2, ErrorMessage = "Họ và tên phải từ 2 đến 100 ký tự.")]
        [Display(Name = "Họ và tên")]
        public string FullName { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập email.")]
        [EmailAddress(ErrorMessage = "Email không đúng định dạng.")]
        [StringLength(100, ErrorMessage = "Email tối đa 100 ký tự.")]
        [Display(Name = "Email")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập số điện thoại.")]
        [RegularExpression(@"^(0|\+84)[0-9]{9,10}$", ErrorMessage = "Số điện thoại Việt Nam không đúng định dạng.")]
        [StringLength(20)]
        [Display(Name = "Số điện thoại")]
        public string Phone { get; set; }
    }

    public class CandidateChangePasswordViewModel
    {
        [Required(ErrorMessage = "Vui lòng nhập mật khẩu hiện tại.")]
        [DataType(DataType.Password)]
        [Display(Name = "Mật khẩu hiện tại")]
        public string CurrentPassword { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập mật khẩu mới.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "Mật khẩu mới phải từ 8 đến 100 ký tự.")]
        [RegularExpression(
            @"^(?=.*[A-Za-z])(?=.*\d).{8,100}$",
            ErrorMessage = "Mật khẩu mới phải có ít nhất một chữ cái và một chữ số.")]
        [DataType(DataType.Password)]
        [Display(Name = "Mật khẩu mới")]
        public string NewPassword { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập lại mật khẩu mới.")]
        [DataType(DataType.Password)]
        [Compare("NewPassword", ErrorMessage = "Mật khẩu xác nhận không khớp.")]
        [Display(Name = "Xác nhận mật khẩu mới")]
        public string ConfirmPassword { get; set; }
    }
}
