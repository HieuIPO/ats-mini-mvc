using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Account;
using UserEntity = ATSMiniProject.Models.User;

namespace ATSMiniProject.Controllers
{
    public class AccountController : Controller
    {
        private static readonly string[] BackOfficeRoles = { "Admin", "HR" };

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
                    ModelState.AddModelError(string.Empty, "Tai khoan dang tam khoa. Vui long thu lai sau.");
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
                    db.AuditLogs.Add(CreateAuditLog(user.UserID, "LOGIN_FORBIDDEN", "Tai khoan khong co quyen vao khu vuc quan tri."));
                    db.SaveChanges();
                    ModelState.AddModelError(string.Empty, "Tai khoan khong co quyen truy cap khu vuc quan tri.");
                    return View(model);
                }

                user.FailedLoginCount = 0;
                user.LockedUntil = null;
                user.LastLoginAt = DateTime.Now;
                user.UpdatedAt = DateTime.Now;
                db.AuditLogs.Add(CreateAuditLog(user.UserID, "LOGIN_SUCCESS", "Dang nhap thanh cong."));
                db.SaveChanges();

                SignIn(user);
                TempData["Success"] = "Dang nhap thanh cong.";
                return RedirectAfterLogin(model.ReturnUrl);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Logout()
        {
            Session.Clear();
            Session.Abandon();
            TempData["Success"] = "Da dang xuat.";
            return RedirectToAction("Login", "Account");
        }

        [HttpGet]
        public ActionResult AccessDenied(string returnUrl)
        {
            Response.StatusCode = 403;
            ViewBag.ReturnUrl = returnUrl;
            return View();
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

            db.AuditLogs.Add(CreateAuditLog(user.UserID, "LOGIN_FAILED", "Dang nhap that bai."));
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
            ModelState.AddModelError(string.Empty, "Ten dang nhap hoac mat khau khong dung.");
        }

        private ActionResult RedirectAfterLogin(string returnUrl)
        {
            if (Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }

            return RedirectToAction("Index", "Dashboard");
        }
    }
}
