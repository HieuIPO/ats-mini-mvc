using System;
using System.Data.Entity;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Account;
using UserEntity = ATSMiniProject.Models.User;

namespace ATSMiniProject.Controllers
{
    public class AccountController : Controller
    {
        private static readonly string[] BackOfficeRoles = { "Admin", "HR" };
        private static readonly string[] AllowedAvatarExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

        [HttpGet]
        public ActionResult Login(string returnUrl)
        {
            if (Session[AuthSessionKeys.UserID] != null)
            {
                return RedirectAfterLogin(returnUrl);
            }

            return View(new LoginViewModel { ReturnUrl = returnUrl });
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(LoginViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var username = model.Username.Trim();

            using (var db = new ATSMiniDBContext())
            {
                var user = db.Users
                    .Include(u => u.Role)
                    .SingleOrDefault(u => u.Username == username);

                if (user == null || !user.IsActive)
                {
                    AddInvalidLoginError();
                    return View(model);
                }

                if (user.LockedUntil.HasValue && user.LockedUntil.Value > DateTime.Now)
                {
                    ModelState.AddModelError(string.Empty, "Tài khoản đang tạm khoá. Vui lòng thử lại sau.");
                    return View(model);
                }

                if (!PasswordHashHelper.VerifySha256Hex(user.PasswordSalt, model.Password, user.PasswordHash))
                {
                    RegisterFailedLogin(db, user);
                    AddInvalidLoginError();
                    return View(model);
                }

                if (!CanAccessBackOffice(user))
                {
                    db.AuditLogs.Add(CreateAuditLog(user.UserID, "LOGIN_FORBIDDEN", "Tài khoản không có quyền vào khu vực quản trị."));
                    db.SaveChanges();
                    ModelState.AddModelError(string.Empty, "Tài khoản không có quyền truy cập khu vực quản trị.");
                    return View(model);
                }

                user.FailedLoginCount = 0;
                user.LockedUntil = null;
                user.LastLoginAt = DateTime.Now;
                user.UpdatedAt = DateTime.Now;
                db.AuditLogs.Add(CreateAuditLog(user.UserID, "LOGIN_SUCCESS", "Đăng nhập thành công."));
                db.SaveChanges();

                SignIn(user);
                TempData["Success"] = "Đăng nhập thành công.";
                return RedirectAfterLogin(model.ReturnUrl);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            TempData["Success"] = "Đã đăng xuất.";
            return RedirectToAction("Login", "Account");
        }

        [HttpGet]
        public ActionResult AccessDenied(string returnUrl)
        {
            Response.StatusCode = 403;
            ViewBag.ReturnUrl = returnUrl;
            return View();
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        [ActionName("Profile")]
        public ActionResult ProfilePage()
        {
            var userId = Session[AuthSessionKeys.UserID] as int?;
            if (!userId.HasValue)
            {
                return RedirectToAction("Login");
            }

            using (var db = new ATSMiniDBContext())
            {
                var user = db.Users.Include(u => u.Role).SingleOrDefault(u => u.UserID == userId.Value);
                if (user == null)
                {
                    return HttpNotFound();
                }

                return View(new ProfileViewModel
                {
                    Username = user.Username,
                    FullName = user.FullName,
                    Email = user.Email,
                    Phone = user.Phone,
                    RoleName = user.Role == null ? string.Empty : user.Role.RoleName,
                    AvatarPath = Session["AuthAvatarPath"] as string
                });
            }
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        [ActionName("Profile")]
        public ActionResult ProfilePage(ProfileViewModel model)
        {
            var userId = Session[AuthSessionKeys.UserID] as int?;
            if (!userId.HasValue)
            {
                return RedirectToAction("Login");
            }

            if (!ModelState.IsValid)
            {
                FillProfileMeta(model);
                return View(model);
            }

            using (var db = new ATSMiniDBContext())
            {
                var user = db.Users.Include(u => u.Role).SingleOrDefault(u => u.UserID == userId.Value);
                if (user == null)
                {
                    return HttpNotFound();
                }

                var email = model.Email.Trim();
                if (db.Users.Any(u => u.UserID != user.UserID && u.Email == email))
                {
                    ModelState.AddModelError("Email", "Email này đang được tài khoản khác sử dụng.");
                    FillProfileMeta(model, user);
                    return View(model);
                }

                var avatarPath = SaveAvatarIfProvided(model.AvatarFile);
                if (ModelState.IsValid == false)
                {
                    FillProfileMeta(model, user);
                    return View(model);
                }

                user.FullName = model.FullName.Trim();
                user.Email = email;
                user.Phone = string.IsNullOrWhiteSpace(model.Phone) ? null : model.Phone.Trim();
                user.UpdatedAt = DateTime.Now;
                db.SaveChanges();

                Session[AuthSessionKeys.FullName] = user.FullName;
                Session["AuthEmail"] = user.Email;
                Session["AuthPhone"] = user.Phone;
                if (!string.IsNullOrWhiteSpace(avatarPath))
                {
                    Session["AuthAvatarPath"] = avatarPath;
                }

                TempData["Success"] = "Đã cập nhật thông tin cá nhân.";
                return RedirectToAction("Profile");
            }
        }

        private void SignIn(UserEntity user)
        {
            Session[AuthSessionKeys.UserID] = user.UserID;
            Session[AuthSessionKeys.Username] = user.Username;
            Session[AuthSessionKeys.FullName] = user.FullName;
            Session[AuthSessionKeys.RoleName] = user.Role == null ? string.Empty : user.Role.RoleName;
        }

        private bool CanAccessBackOffice(UserEntity user)
        {
            var roleName = user.Role == null ? string.Empty : user.Role.RoleName;
            return BackOfficeRoles.Any(role => string.Equals(role, roleName, StringComparison.OrdinalIgnoreCase));
        }

        private void RegisterFailedLogin(ATSMiniDBContext db, UserEntity user)
        {
            user.FailedLoginCount += 1;
            user.UpdatedAt = DateTime.Now;

            if (user.FailedLoginCount >= 5)
            {
                user.LockedUntil = DateTime.Now.AddMinutes(15);
            }

            db.AuditLogs.Add(CreateAuditLog(user.UserID, "LOGIN_FAILED", "Đăng nhập thất bại."));
            db.SaveChanges();
        }

        private AuditLog CreateAuditLog(int userId, string actionName, string description)
        {
            return new AuditLog
            {
                UserID = userId,
                ActionName = actionName,
                TableName = "Users",
                RecordID = userId,
                Description = description,
                CreatedAt = DateTime.Now,
                IpAddress = Request.UserHostAddress
            };
        }

        private void AddInvalidLoginError()
        {
            ModelState.AddModelError(string.Empty, "Tên đăng nhập hoặc mật khẩu không đúng.");
        }

        private ActionResult RedirectAfterLogin(string returnUrl)
        {
            if (Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }

            return RedirectToAction("Index", "Dashboard");
        }

        private string SaveAvatarIfProvided(HttpPostedFileBase avatarFile)
        {
            if (avatarFile == null || avatarFile.ContentLength == 0)
            {
                return null;
            }

            if (avatarFile.ContentLength > 2 * 1024 * 1024)
            {
                ModelState.AddModelError("AvatarFile", "Ảnh đại diện không được vượt quá 2MB.");
                return null;
            }

            var extension = Path.GetExtension(avatarFile.FileName);
            if (string.IsNullOrWhiteSpace(extension) || !AllowedAvatarExtensions.Contains(extension.ToLowerInvariant()))
            {
                ModelState.AddModelError("AvatarFile", "Ảnh đại diện chỉ nhận JPG, PNG hoặc GIF.");
                return null;
            }

            var folder = Server.MapPath("~/Uploads/Avatars/");
            Directory.CreateDirectory(folder);

            var storedFileName = "avatar-" + Session[AuthSessionKeys.UserID] + "-" + DateTime.Now.ToString("yyyyMMddHHmmss") + extension.ToLowerInvariant();
            var physicalPath = Path.Combine(folder, storedFileName);
            avatarFile.SaveAs(physicalPath);

            return "~/Uploads/Avatars/" + storedFileName;
        }

        private void FillProfileMeta(ProfileViewModel model, UserEntity user = null)
        {
            model.RoleName = user != null && user.Role != null ? user.Role.RoleName : Session[AuthSessionKeys.RoleName] as string;
            model.Username = user != null ? user.Username : Session[AuthSessionKeys.Username] as string;
            model.AvatarPath = Session["AuthAvatarPath"] as string;
        }
    }
}
