using System.ComponentModel.DataAnnotations;

namespace ATSMiniProject.ViewModels.Account
{
    public class LoginViewModel
    {
        [Required(ErrorMessage = "Vui long nhap ten dang nhap.")]
        [StringLength(50, ErrorMessage = "Ten dang nhap toi da 50 ky tu.")]
        [Display(Name = "Ten dang nhap")]
        public string Username { get; set; }

        [Required(ErrorMessage = "Vui long nhap mat khau.")]
        [DataType(DataType.Password)]
        [Display(Name = "Mat khau")]
        public string Password { get; set; }

        public string ReturnUrl { get; set; }
    }
}
