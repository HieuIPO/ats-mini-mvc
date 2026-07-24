using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
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

                if (user == null || !user.IsActive || user.Role == null || !user.Role.IsActive)
                {
                    AddInvalidLoginError();
                    return View(model);
                }

                if (user.LockedUntil.HasValue && user.LockedUntil.Value > DateTime.Now)
                {
                    ModelState.AddModelError(string.Empty, "Tài khoản đang tạm khóa. Vui lòng thử lại sau.");
                    return View(model);
                }

                if (user.LockedUntil.HasValue)
                {
                    user.FailedLoginCount = 0;
                    user.LockedUntil = null;
                }

                if (!PasswordHashHelper.VerifyPassword(user.PasswordSalt, model.Password, user.PasswordHash))
                {
                    RegisterFailedLogin(db, user);
                    AddInvalidLoginError();
                    return View(model);
                }

                if (PasswordHashHelper.NeedsRehash(user.PasswordHash))
                {
                    var upgradedSalt = PasswordHashHelper.GenerateSalt();
                    user.PasswordSalt = upgradedSalt;
                    user.PasswordHash = PasswordHashHelper.HashPassword(upgradedSalt, model.Password);
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

        [HttpGet]
        public ActionResult Register()
        {
            if (Session[AuthSessionKeys.UserID] != null)
            {
                return RedirectAfterLogin(null);
            }

            return View(new RegisterViewModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Register(RegisterViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var username = model.Username.Trim();
            var normalizedEmail = model.Email.Trim().ToLowerInvariant();

            using (var db = new ATSMiniDBContext())
            {
                if (db.Users.Any(u => u.Username == username))
                {
                    ModelState.AddModelError("Username", "Tên đăng nhập đã được sử dụng.");
                }

                if (db.Users.Any(u => u.Email == normalizedEmail))
                {
                    ModelState.AddModelError("Email", "Email đã được sử dụng.");
                }

                var candidateRole = db.Roles.SingleOrDefault(r => r.RoleName == "Candidate" && r.IsActive);
                if (candidateRole == null)
                {
                    ModelState.AddModelError(string.Empty, "Hệ thống chưa cấu hình vai trò ứng viên.");
                }

                if (!ModelState.IsValid)
                {
                    return View(model);
                }

                using (var transaction = db.Database.BeginTransaction())
                {
                    try
                    {
                        var salt = PasswordHashHelper.GenerateSalt();
                        var user = new UserEntity
                        {
                            Username = username,
                            PasswordSalt = salt,
                            PasswordHash = PasswordHashHelper.HashPassword(salt, model.Password),
                            FullName = model.FullName.Trim(),
                            Email = normalizedEmail,
                            Phone = model.Phone.Trim(),
                            RoleID = candidateRole.RoleID,
                            Role = candidateRole,
                            FailedLoginCount = 0,
                            IsActive = true,
                            CreatedAt = DateTime.Now
                        };

                        db.Users.Add(user);
                        db.SaveChanges();
                        db.AuditLogs.Add(CreateAuditLog(user.UserID, "REGISTER_CANDIDATE", "Ứng viên tạo tài khoản."));
                        db.SaveChanges();
                        transaction.Commit();

                        SignIn(user);
                    }
                    catch (DbUpdateException)
                    {
                        transaction.Rollback();
                        ModelState.AddModelError(string.Empty, "Tên đăng nhập hoặc email đã tồn tại. Vui lòng kiểm tra lại.");
                        return View(model);
                    }
                }

                TempData["Success"] = "Tạo tài khoản thành công. Chào mừng bạn đến ATS Careers.";
                return RedirectToAction("Index", "Candidate");
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

        private void SignIn(UserEntity user)
        {
            Session.Clear();
            Session[AuthSessionKeys.UserID] = user.UserID;
            Session[AuthSessionKeys.Username] = user.Username;
            Session[AuthSessionKeys.FullName] = user.FullName;
            Session[AuthSessionKeys.RoleName] = user.Role == null ? string.Empty : user.Role.RoleName;
            Session[AuthSessionKeys.AvatarVersion] = DateTime.UtcNow.Ticks;
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

            var roleName = Session[AuthSessionKeys.RoleName] as string;
            if (string.Equals(roleName, "Candidate", StringComparison.OrdinalIgnoreCase))
            {
                return RedirectToAction("Index", "Candidate");
            }

            return RedirectToAction("Index", "Dashboard");
        }
    }
}
