using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;

namespace ATSMiniProject.ViewModels.Admin
{
    public class UserManagementListViewModel
    {
        public UserManagementListViewModel()
        {
            Users = new List<UserListItemViewModel>();
            RoleOptions = new List<SelectListItem>();
        }

        public string Keyword { get; set; }
        public int? RoleId { get; set; }
        public string Status { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public int ActiveCount { get; set; }
        public int InactiveCount { get; set; }
        public int LockedCount { get; set; }
        public IList<UserListItemViewModel> Users { get; set; }
        public IList<SelectListItem> RoleOptions { get; set; }
    }

    public class UserListItemViewModel
    {
        public int UserId { get; set; }
        public string Username { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Phone { get; set; }
        public string RoleName { get; set; }
        public string AvatarUrl { get; set; }
        public bool IsActive { get; set; }
        public bool IsLocked { get; set; }
        public bool IsCurrentUser { get; set; }
        public DateTime? LockedUntil { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public abstract class UserDetailsViewModel
    {
        [Required(ErrorMessage = "Vui lòng nhập họ và tên.")]
        [StringLength(100, ErrorMessage = "Họ và tên không được vượt quá 100 ký tự.")]
        [Display(Name = "Họ và tên")]
        public string FullName { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập email.")]
        [EmailAddress(ErrorMessage = "Email không đúng định dạng.")]
        [StringLength(100, ErrorMessage = "Email không được vượt quá 100 ký tự.")]
        public string Email { get; set; }

        [StringLength(20, ErrorMessage = "Số điện thoại không được vượt quá 20 ký tự.")]
        [RegularExpression(@"^[0-9+() .-]*$", ErrorMessage = "Số điện thoại chứa ký tự không hợp lệ.")]
        [Display(Name = "Số điện thoại")]
        public string Phone { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn vai trò.")]
        [Display(Name = "Vai trò")]
        public int? RoleId { get; set; }

        public IList<SelectListItem> RoleOptions { get; set; }
    }

    public class UserCreateViewModel : UserDetailsViewModel
    {
        public UserCreateViewModel()
        {
            RoleOptions = new List<SelectListItem>();
            IsActive = true;
        }

        [Required(ErrorMessage = "Vui lòng nhập tên đăng nhập.")]
        [StringLength(50, MinimumLength = 3, ErrorMessage = "Tên đăng nhập phải từ 3 đến 50 ký tự.")]
        [RegularExpression(@"^[A-Za-z0-9._-]+$", ErrorMessage = "Tên đăng nhập chỉ gồm chữ không dấu, số, dấu chấm, gạch dưới hoặc gạch ngang.")]
        [Display(Name = "Tên đăng nhập")]
        public string Username { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập mật khẩu ban đầu.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "Mật khẩu phải có ít nhất 8 ký tự.")]
        [DataType(DataType.Password)]
        [Display(Name = "Mật khẩu ban đầu")]
        public string Password { get; set; }

        [Required(ErrorMessage = "Vui lòng xác nhận mật khẩu.")]
        [System.ComponentModel.DataAnnotations.Compare("Password", ErrorMessage = "Mật khẩu xác nhận không khớp.")]
        [DataType(DataType.Password)]
        [Display(Name = "Xác nhận mật khẩu")]
        public string ConfirmPassword { get; set; }

        [Display(Name = "Cho phép đăng nhập ngay")]
        public bool IsActive { get; set; }
    }

    public class UserEditViewModel : UserDetailsViewModel
    {
        public UserEditViewModel()
        {
            RoleOptions = new List<SelectListItem>();
        }

        public int UserId { get; set; }
        public string Username { get; set; }
        public bool IsActive { get; set; }
        public bool IsLocked { get; set; }
        public bool IsCurrentUser { get; set; }
        public bool CanChangeRole { get; set; }
        public DateTime? LockedUntil { get; set; }
        public DateTime? LastLoginAt { get; set; }
    }

    public class UserResetPasswordViewModel
    {
        [Required]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập mật khẩu mới.")]
        [StringLength(100, MinimumLength = 8, ErrorMessage = "Mật khẩu phải có ít nhất 8 ký tự.")]
        [DataType(DataType.Password)]
        [Display(Name = "Mật khẩu mới")]
        public string NewPassword { get; set; }

        [Required(ErrorMessage = "Vui lòng xác nhận mật khẩu mới.")]
        [System.ComponentModel.DataAnnotations.Compare("NewPassword", ErrorMessage = "Mật khẩu xác nhận không khớp.")]
        [DataType(DataType.Password)]
        [Display(Name = "Xác nhận mật khẩu mới")]
        public string ConfirmPassword { get; set; }
    }
}
