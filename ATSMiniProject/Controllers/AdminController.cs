using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Admin;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Admin")]
    public class AdminController : Controller
    {
        private const int UsersPerPage = 15;

        [HttpGet]
        public ActionResult Users(string keyword, int? roleId, string status = "all", int page = 1)
        {
            using (var db = new ATSMiniDBContext())
            {
                var now = DateTime.Now;
                var currentUserId = CurrentUserId();
                var normalizedStatus = NormalizeStatus(status);
                var query = db.Users.AsNoTracking().Include(u => u.Role);

                if (!string.IsNullOrWhiteSpace(keyword))
                {
                    var trimmed = keyword.Trim();
                    query = query.Where(u =>
                        u.Username.Contains(trimmed) ||
                        u.FullName.Contains(trimmed) ||
                        u.Email.Contains(trimmed) ||
                        (u.Phone != null && u.Phone.Contains(trimmed)));
                }

                if (roleId.HasValue)
                {
                    query = query.Where(u => u.RoleID == roleId.Value);
                }

                if (normalizedStatus == "active")
                {
                    query = query.Where(u => u.IsActive && (!u.LockedUntil.HasValue || u.LockedUntil <= now));
                }
                else if (normalizedStatus == "inactive")
                {
                    query = query.Where(u => !u.IsActive);
                }
                else if (normalizedStatus == "locked")
                {
                    query = query.Where(u => u.IsActive && u.LockedUntil.HasValue && u.LockedUntil > now);
                }

                var totalItems = query.Count();
                var totalPages = Math.Max(1, (int)Math.Ceiling(totalItems / (double)UsersPerPage));
                page = Math.Max(1, Math.Min(page, totalPages));

                var users = query
                    .OrderByDescending(u => u.IsActive)
                    .ThenBy(u => u.FullName)
                    .Skip((page - 1) * UsersPerPage)
                    .Take(UsersPerPage)
                    .Select(u => new UserListItemViewModel
                    {
                        UserId = u.UserID,
                        Username = u.Username,
                        FullName = u.FullName,
                        Email = u.Email,
                        Phone = u.Phone,
                        RoleName = u.Role.RoleName,
                        IsActive = u.IsActive,
                        IsLocked = u.IsActive && u.LockedUntil.HasValue && u.LockedUntil > now,
                        IsCurrentUser = u.UserID == currentUserId,
                        LockedUntil = u.LockedUntil,
                        LastLoginAt = u.LastLoginAt,
                        CreatedAt = u.CreatedAt
                    })
                    .ToList();

                var avatarFolder = Server.MapPath("~/Uploads/Avatars/");
                foreach (var user in users)
                {
                    var avatarFileName = AccountAvatarPathResolver.FindLatestFileName(
                        avatarFolder,
                        user.UserId);
                    user.AvatarUrl = string.IsNullOrWhiteSpace(avatarFileName)
                        ? null
                        : "~/Uploads/Avatars/" + avatarFileName;
                }

                var model = new UserManagementListViewModel
                {
                    Keyword = keyword == null ? null : keyword.Trim(),
                    RoleId = roleId,
                    Status = normalizedStatus,
                    Page = page,
                    TotalPages = totalPages,
                    TotalItems = totalItems,
                    ActiveCount = db.Users.Count(u => u.IsActive && (!u.LockedUntil.HasValue || u.LockedUntil <= now)),
                    InactiveCount = db.Users.Count(u => !u.IsActive),
                    LockedCount = db.Users.Count(u => u.IsActive && u.LockedUntil.HasValue && u.LockedUntil > now),
                    Users = users,
                    RoleOptions = BuildRoleOptions(db, roleId)
                };

                return View(model);
            }
        }

        [HttpGet]
        public ActionResult UserCreate()
        {
            using (var db = new ATSMiniDBContext())
            {
                var model = new UserCreateViewModel
                {
                    IsActive = true,
                    RoleOptions = BuildInternalRoleOptions(db, null)
                };
                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UserCreate(UserCreateViewModel model)
        {
            using (var db = new ATSMiniDBContext())
            {
                NormalizeUserDetails(model);
                ValidatePasswordStrength(model.Password, "Password");
                ValidateInternalRole(db, model.RoleId);
                ValidateUniqueUser(db, model.Username, model.Email, null);

                if (!ModelState.IsValid)
                {
                    model.RoleOptions = BuildInternalRoleOptions(db, model.RoleId);
                    return View(model);
                }

                var salt = PasswordHashHelper.GenerateSalt();
                var user = new User
                {
                    Username = model.Username.Trim(),
                    PasswordSalt = salt,
                    PasswordHash = PasswordHashHelper.HashPassword(salt, model.Password),
                    FullName = model.FullName,
                    Email = model.Email,
                    Phone = NormalizeOptional(model.Phone),
                    RoleID = model.RoleId.Value,
                    FailedLoginCount = 0,
                    LockedUntil = null,
                    IsActive = model.IsActive,
                    CreatedAt = DateTime.Now
                };

                db.Users.Add(user);
                db.SaveChanges();
                db.AuditLogs.Add(CreateAuditLog(
                    "CREATE_USER",
                    user.UserID,
                    "Tạo tài khoản " + user.Username + "."));
                db.SaveChanges();

                TempData["Success"] = "Đã tạo tài khoản " + user.Username + ".";
                return RedirectToAction("Users");
            }
        }

        [HttpGet]
        public ActionResult UserEdit(int id)
        {
            using (var db = new ATSMiniDBContext())
            {
                var now = DateTime.Now;
                var user = db.Users.AsNoTracking().Include(u => u.Role).SingleOrDefault(u => u.UserID == id);
                if (user == null)
                {
                    return HttpNotFound();
                }

                var model = new UserEditViewModel
                {
                    UserId = user.UserID,
                    Username = user.Username,
                    FullName = user.FullName,
                    Email = user.Email,
                    Phone = user.Phone,
                    RoleId = user.RoleID,
                    IsActive = user.IsActive,
                    IsLocked = user.IsActive && user.LockedUntil.HasValue && user.LockedUntil > now,
                    IsCurrentUser = user.UserID == CurrentUserId(),
                    CanChangeRole = user.UserID != CurrentUserId() && InternalAccountRolePolicy.IsAllowedRoleName(user.Role.RoleName),
                    LockedUntil = user.LockedUntil,
                    LastLoginAt = user.LastLoginAt,
                    RoleOptions = BuildEditRoleOptions(db, user.RoleID)
                };

                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UserEdit(UserEditViewModel model)
        {
            using (var db = new ATSMiniDBContext())
            {
                NormalizeUserDetails(model);
                ValidateUniqueUser(db, null, model.Email, model.UserId);

                var user = db.Users.Include(u => u.Role).SingleOrDefault(u => u.UserID == model.UserId);
                if (user == null)
                {
                    return HttpNotFound();
                }

                var isCurrentUser = user.UserID == CurrentUserId();
                var isInternalAccount = InternalAccountRolePolicy.IsAllowedRoleName(user.Role.RoleName);
                if (isCurrentUser && model.RoleId.HasValue && model.RoleId.Value != user.RoleID)
                {
                    ModelState.AddModelError("RoleId", "Bạn không thể tự thay đổi vai trò của chính mình.");
                }
                else if (!isInternalAccount && model.RoleId.HasValue && model.RoleId.Value != user.RoleID)
                {
                    ModelState.AddModelError("RoleId", "Không thể đổi tài khoản ứng viên thành tài khoản nội bộ tại đây.");
                }
                else if (isInternalAccount && !isCurrentUser)
                {
                    ValidateInternalRole(db, model.RoleId);
                }

                if (!ModelState.IsValid)
                {
                    var now = DateTime.Now;
                    model.Username = user.Username;
                    model.IsActive = user.IsActive;
                    model.IsLocked = user.IsActive && user.LockedUntil.HasValue && user.LockedUntil > now;
                    model.IsCurrentUser = isCurrentUser;
                    model.CanChangeRole = !isCurrentUser && isInternalAccount;
                    model.LockedUntil = user.LockedUntil;
                    model.LastLoginAt = user.LastLoginAt;
                    model.RoleOptions = BuildEditRoleOptions(db, user.RoleID);
                    return View(model);
                }

                user.FullName = model.FullName;
                user.Email = model.Email;
                user.Phone = NormalizeOptional(model.Phone);
                user.RoleID = model.RoleId.Value;
                user.UpdatedAt = DateTime.Now;
                db.SaveChanges();

                db.AuditLogs.Add(CreateAuditLog(
                    "UPDATE_USER",
                    user.UserID,
                    "Cập nhật thông tin tài khoản " + user.Username + "."));
                db.SaveChanges();

                if (isCurrentUser)
                {
                    Session[AuthSessionKeys.FullName] = user.FullName;
                }

                TempData["Success"] = "Đã cập nhật tài khoản " + user.Username + ".";
                return RedirectToAction("UserEdit", new { id = user.UserID });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UpdateUserAccess(int id, string command)
        {
            using (var db = new ATSMiniDBContext())
            {
                var user = db.Users.SingleOrDefault(u => u.UserID == id);
                if (user == null)
                {
                    return HttpNotFound();
                }

                if (user.UserID == CurrentUserId())
                {
                    TempData["Error"] = "Bạn không thể khóa hoặc thay đổi trạng thái tài khoản đang đăng nhập.";
                    return RedirectToAction("Users");
                }

                var normalizedCommand = (command ?? string.Empty).Trim().ToLowerInvariant();
                string auditAction;
                string successMessage;

                if (normalizedCommand == "activate")
                {
                    user.IsActive = true;
                    user.FailedLoginCount = 0;
                    user.LockedUntil = null;
                    auditAction = "ACTIVATE_USER";
                    successMessage = "Đã mở tài khoản " + user.Username + ".";
                }
                else if (normalizedCommand == "deactivate")
                {
                    user.IsActive = false;
                    auditAction = "DEACTIVATE_USER";
                    successMessage = "Đã tạm khóa tài khoản " + user.Username + ".";
                }
                else if (normalizedCommand == "unlock")
                {
                    user.IsActive = true;
                    user.FailedLoginCount = 0;
                    user.LockedUntil = null;
                    auditAction = "UNLOCK_USER";
                    successMessage = "Đã mở khóa đăng nhập cho " + user.Username + ".";
                }
                else
                {
                    return new HttpStatusCodeResult(400);
                }

                user.UpdatedAt = DateTime.Now;
                db.AuditLogs.Add(CreateAuditLog(
                    auditAction,
                    user.UserID,
                    successMessage));
                db.SaveChanges();

                TempData["Success"] = successMessage;
                return RedirectToAction("Users");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ResetUserPassword(UserResetPasswordViewModel model)
        {
            ValidatePasswordStrength(model.NewPassword, "NewPassword");

            using (var db = new ATSMiniDBContext())
            {
                var user = db.Users.SingleOrDefault(u => u.UserID == model.UserId);
                if (user == null)
                {
                    return HttpNotFound();
                }

                if (!ModelState.IsValid)
                {
                    TempData["Error"] = FirstModelError("Mật khẩu mới không hợp lệ.");
                    return RedirectToAction("UserEdit", new { id = model.UserId });
                }

                var salt = PasswordHashHelper.GenerateSalt();
                user.PasswordSalt = salt;
                user.PasswordHash = PasswordHashHelper.HashPassword(salt, model.NewPassword);
                user.FailedLoginCount = 0;
                user.LockedUntil = null;
                user.UpdatedAt = DateTime.Now;
                db.AuditLogs.Add(CreateAuditLog(
                    "RESET_USER_PASSWORD",
                    user.UserID,
                    "Đặt lại mật khẩu tài khoản " + user.Username + "."));
                db.SaveChanges();

                TempData["Success"] = "Đã đặt lại mật khẩu cho " + user.Username + ".";
                return RedirectToAction("UserEdit", new { id = user.UserID });
            }
        }

        private static string NormalizeStatus(string status)
        {
            var normalized = (status ?? "all").Trim().ToLowerInvariant();
            return normalized == "active" || normalized == "inactive" || normalized == "locked"
                ? normalized
                : "all";
        }

        private void ValidateUniqueUser(
            ATSMiniDBContext db,
            string username,
            string email,
            int? excludedUserId)
        {
            if (!string.IsNullOrWhiteSpace(username))
            {
                var trimmedUsername = username.Trim();
                if (db.Users.Any(u =>
                    (!excludedUserId.HasValue || u.UserID != excludedUserId.Value) &&
                    u.Username == trimmedUsername))
                {
                    ModelState.AddModelError("Username", "Tên đăng nhập đã được sử dụng.");
                }
            }

            if (!string.IsNullOrWhiteSpace(email))
            {
                var trimmedEmail = email.Trim();
                if (db.Users.Any(u =>
                    (!excludedUserId.HasValue || u.UserID != excludedUserId.Value) &&
                    u.Email == trimmedEmail))
                {
                    ModelState.AddModelError("Email", "Email đã được sử dụng.");
                }
            }
        }

        private void ValidateInternalRole(ATSMiniDBContext db, int? roleId)
        {
            if (!roleId.HasValue)
            {
                return;
            }

            var roleName = db.Roles
                .Where(r => r.RoleID == roleId.Value && r.IsActive)
                .Select(r => r.RoleName)
                .SingleOrDefault();

            if (!InternalAccountRolePolicy.IsAllowedRoleName(roleName))
            {
                ModelState.AddModelError("RoleId", "Tài khoản nội bộ chỉ được chọn vai trò Admin hoặc HR.");
            }
        }

        private void ValidatePasswordStrength(string password, string key)
        {
            if (string.IsNullOrEmpty(password))
            {
                return;
            }

            if (!password.Any(char.IsUpper) ||
                !password.Any(char.IsLower) ||
                !password.Any(char.IsDigit))
            {
                ModelState.AddModelError(key, "Mật khẩu phải có chữ hoa, chữ thường và chữ số.");
            }
        }

        private static void NormalizeUserDetails(UserDetailsViewModel model)
        {
            model.FullName = model.FullName == null ? null : model.FullName.Trim();
            model.Email = model.Email == null ? null : model.Email.Trim();
            model.Phone = NormalizeOptional(model.Phone);
        }

        private static string NormalizeOptional(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private AuditLog CreateAuditLog(string actionName, int recordId, string description)
        {
            return new AuditLog
            {
                UserID = CurrentUserId(),
                ActionName = actionName,
                TableName = "Users",
                RecordID = recordId,
                Description = description,
                CreatedAt = DateTime.Now,
                IpAddress = Request.UserHostAddress
            };
        }

        private string FirstModelError(string fallback)
        {
            return ModelState.Values
                .SelectMany(value => value.Errors)
                .Select(error => error.ErrorMessage)
                .FirstOrDefault(message => !string.IsNullOrWhiteSpace(message)) ?? fallback;
        }

        private static System.Collections.Generic.IList<SelectListItem> BuildRoleOptions(
            ATSMiniDBContext db,
            int? selectedRoleId)
        {
            return db.Roles
                .AsNoTracking()
                .Where(r => r.IsActive)
                .OrderBy(r => r.RoleID)
                .Select(r => new SelectListItem
                {
                    Value = r.RoleID.ToString(),
                    Text = r.RoleName,
                    Selected = selectedRoleId.HasValue && r.RoleID == selectedRoleId.Value
                })
                .ToList();
        }

        private static System.Collections.Generic.IList<SelectListItem> BuildInternalRoleOptions(
            ATSMiniDBContext db,
            int? selectedRoleId)
        {
            return db.Roles
                .AsNoTracking()
                .Where(r => r.IsActive &&
                    (r.RoleName == InternalAccountRolePolicy.AdminRoleName ||
                     r.RoleName == InternalAccountRolePolicy.HrRoleName))
                .OrderBy(r => r.RoleID)
                .Select(r => new SelectListItem
                {
                    Value = r.RoleID.ToString(),
                    Text = r.RoleName,
                    Selected = selectedRoleId.HasValue && r.RoleID == selectedRoleId.Value
                })
                .ToList();
        }

        private static System.Collections.Generic.IList<SelectListItem> BuildEditRoleOptions(
            ATSMiniDBContext db,
            int selectedRoleId)
        {
            var selectedRoleName = db.Roles
                .AsNoTracking()
                .Where(r => r.RoleID == selectedRoleId)
                .Select(r => r.RoleName)
                .SingleOrDefault();

            if (InternalAccountRolePolicy.IsAllowedRoleName(selectedRoleName))
            {
                return BuildInternalRoleOptions(db, selectedRoleId);
            }

            return db.Roles
                .AsNoTracking()
                .Where(r => r.RoleID == selectedRoleId)
                .Select(r => new SelectListItem
                {
                    Value = r.RoleID.ToString(),
                    Text = r.RoleName,
                    Selected = true
                })
                .ToList();
        }

        private int CurrentUserId()
        {
            return Convert.ToInt32(Session[AuthSessionKeys.UserID]);
        }
    }
}
