using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Candidate;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Candidate")]
    public class CandidateController : Controller
    {
        private const int SavedJobsPageSize = 9;

        [HttpGet]
        public ActionResult Index()
        {
            var userId = GetCurrentUserId();
            var now = DateTime.Now;
            var today = DateTime.Today;

            using (var db = new ATSMiniDBContext())
            {
                var user = db.Users
                    .AsNoTracking()
                    .SingleOrDefault(u => u.UserID == userId && u.IsActive);
                if (user == null)
                {
                    return HttpNotFound();
                }

                var applicationQuery = db.Applications
                    .AsNoTracking()
                    .Where(a => a.CandidateUserID == userId && !a.IsDeleted);
                var appliedJobIds = applicationQuery.Select(a => a.JobID);
                var upcomingInterviewQuery = db.Interviews
                    .AsNoTracking()
                    .Where(i => !i.IsDeleted &&
                                i.Application.CandidateUserID == userId &&
                                !i.Application.IsDeleted &&
                                i.InterviewDate >= now);

                var recentApplications = applicationQuery
                    .OrderByDescending(a => a.AppliedDate)
                    .Take(4)
                    .Select(a => new ViewModels.Applications.CandidateApplicationItemViewModel
                    {
                        ApplicationId = a.ApplicationID,
                        JobId = a.JobID,
                        JobTitle = a.Job.Title,
                        DepartmentName = a.Job.Department.DepartmentName,
                        Location = a.Job.Location,
                        StatusName = a.ApplicationStatus.StatusName,
                        IsFinal = a.ApplicationStatus.IsFinal,
                        AppliedDate = a.AppliedDate,
                        NextInterviewDate = a.Interviews
                            .Where(i => !i.IsDeleted && i.InterviewDate >= now)
                            .OrderBy(i => i.InterviewDate)
                            .Select(i => (DateTime?)i.InterviewDate)
                            .FirstOrDefault()
                    })
                    .ToList();

                var recommendedJobs = db.Jobs
                    .AsNoTracking()
                    .Where(j => j.IsActive && !j.IsDeleted &&
                                (!j.Deadline.HasValue || j.Deadline.Value >= today) &&
                                !appliedJobIds.Contains(j.JobID))
                    .OrderBy(j => j.Deadline)
                    .ThenByDescending(j => j.CreatedAt)
                    .Take(3)
                    .Select(j => new ViewModels.Jobs.JobCardViewModel
                    {
                        JobId = j.JobID,
                        Title = j.Title,
                        DepartmentName = j.Department.DepartmentName,
                        PositionName = j.JobPosition.PositionName,
                        Location = j.Location,
                        JobType = j.JobType,
                        SalaryRange = j.SalaryRange,
                        Deadline = j.Deadline,
                        IsSaved = j.SavedJobs.Any(s => s.CandidateUserID == userId)
                    })
                    .ToList();

                return View(new CandidateDashboardViewModel
                {
                    FullName = user.FullName,
                    TotalApplications = applicationQuery.Count(),
                    ActiveApplications = applicationQuery.Count(a => !a.ApplicationStatus.IsFinal),
                    UpcomingInterviews = upcomingInterviewQuery.Count(),
                    NextInterviewDate = upcomingInterviewQuery
                        .OrderBy(i => i.InterviewDate)
                        .Select(i => (DateTime?)i.InterviewDate)
                        .FirstOrDefault(),
                    IsProfileComplete = !string.IsNullOrWhiteSpace(user.FullName) &&
                                        !string.IsNullOrWhiteSpace(user.Email) &&
                                        !string.IsNullOrWhiteSpace(user.Phone),
                    RecentApplications = recentApplications,
                    RecommendedJobs = recommendedJobs
                });
            }
        }

        [HttpGet]
        public ActionResult SavedJobs(int page = 1)
        {
            var userId = GetCurrentUserId();
            var today = DateTime.Today;

            using (var db = new ATSMiniDBContext())
            {
                var query = db.SavedJobs
                    .AsNoTracking()
                    .Where(s => s.CandidateUserID == userId && !s.Job.IsDeleted);
                var totalItems = query.Count();
                var pagination = Pagination.Calculate(page, totalItems, SavedJobsPageSize);
                var jobs = query
                    .OrderByDescending(s => s.SavedAt)
                    .ThenByDescending(s => s.SavedJobID)
                    .Skip(pagination.Offset)
                    .Take(pagination.PageSize)
                    .Select(s => new SavedJobItemViewModel
                    {
                        JobId = s.JobID,
                        Title = s.Job.Title,
                        DepartmentName = s.Job.Department.DepartmentName,
                        PositionName = s.Job.JobPosition.PositionName,
                        Location = s.Job.Location,
                        JobType = s.Job.JobType,
                        SalaryRange = s.Job.SalaryRange,
                        SavedAt = s.SavedAt,
                        Deadline = s.Job.Deadline,
                        IsActive = s.Job.IsActive,
                        IsExpired = s.Job.Deadline.HasValue && s.Job.Deadline.Value < today
                    })
                    .ToList();

                return View(new SavedJobListViewModel
                {
                    Page = pagination.Page,
                    TotalPages = pagination.TotalPages,
                    TotalItems = totalItems,
                    Jobs = jobs
                });
            }
        }

        [HttpGet]
        [ActionName("Profile")]
        public ActionResult EditProfile()
        {
            var userId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            {
                var page = BuildProfilePage(db, userId);
                if (page == null)
                {
                    return HttpNotFound();
                }

                return View(page);
            }
        }

        [HttpPost]
        [ActionName("Profile")]
        [ValidateAntiForgeryToken]
        public ActionResult EditProfile(
            [Bind(Prefix = "Profile")] CandidateProfileViewModel model)
        {
            var userId = GetCurrentUserId();
            model.Username = Session[AuthSessionKeys.Username] as string;

            if (!ModelState.IsValid)
            {
                return ProfileViewWithModel(userId, model, null);
            }

            var normalizedEmail = model.Email.Trim().ToLowerInvariant();

            using (var db = new ATSMiniDBContext())
            {
                var user = db.Users.SingleOrDefault(u => u.UserID == userId && u.IsActive);
                if (user == null)
                {
                    return HttpNotFound();
                }

                if (db.Users.Any(u => u.UserID != userId && u.Email == normalizedEmail))
                {
                    ModelState.AddModelError("Profile.Email", "Email đã được sử dụng.");
                    return ProfileViewWithModel(userId, model, null);
                }

                user.FullName = model.FullName.Trim();
                user.Email = normalizedEmail;
                user.Phone = model.Phone.Trim();
                user.UpdatedAt = DateTime.Now;
                db.AuditLogs.Add(new AuditLog
                {
                    UserID = userId,
                    ActionName = "UPDATE_PROFILE",
                    TableName = "Users",
                    RecordID = userId,
                    Description = "Ứng viên cập nhật thông tin cá nhân.",
                    CreatedAt = DateTime.Now,
                    IpAddress = Request.UserHostAddress
                });

                try
                {
                    db.SaveChanges();
                }
                catch (DbUpdateException)
                {
                    ModelState.AddModelError(
                        string.Empty,
                        "Không thể cập nhật hồ sơ. Vui lòng kiểm tra lại thông tin.");
                    return ProfileViewWithModel(userId, model, null);
                }

                Session[AuthSessionKeys.FullName] = user.FullName;
                TempData["Success"] = "Cập nhật hồ sơ thành công.";
                return RedirectToAction("Profile");
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UploadAvatar(HttpPostedFileBase avatarFile)
        {
            var userId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            {
                if (!db.Users.Any(u => u.UserID == userId && u.IsActive))
                {
                    return HttpNotFound();
                }

                var error = CandidateAvatarProcessor.ValidateAndSave(
                    avatarFile,
                    GetAvatarPhysicalPath(userId));
                if (error != null)
                {
                    TempData["Error"] = error;
                    return RedirectToAction("Profile");
                }

                Session[AuthSessionKeys.AvatarVersion] = DateTime.UtcNow.Ticks;
                db.AuditLogs.Add(new AuditLog
                {
                    UserID = userId,
                    ActionName = "UPDATE_AVATAR",
                    TableName = "Users",
                    RecordID = userId,
                    Description = "Ứng viên cập nhật ảnh đại diện.",
                    CreatedAt = DateTime.Now,
                    IpAddress = Request.UserHostAddress
                });

                try
                {
                    db.SaveChanges();
                    TempData["Success"] = "Cập nhật ảnh đại diện thành công.";
                }
                catch (DbUpdateException)
                {
                    TempData["Error"] = "Ảnh đã được lưu nhưng chưa thể ghi nhật ký hệ thống.";
                }
            }

            return RedirectToAction("Profile");
        }

        [HttpGet]
        public ActionResult Avatar()
        {
            var avatarPath = GetAvatarPhysicalPath(GetCurrentUserId());
            if (!System.IO.File.Exists(avatarPath))
            {
                return HttpNotFound();
            }

            Response.Cache.SetCacheability(HttpCacheability.Private);
            Response.Cache.SetMaxAge(TimeSpan.FromDays(1));
            return File(avatarPath, "image/jpeg");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult RemoveAvatar()
        {
            var userId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            {
                if (!db.Users.Any(u => u.UserID == userId && u.IsActive))
                {
                    return HttpNotFound();
                }

                var avatarPath = GetAvatarPhysicalPath(userId);
                try
                {
                    if (System.IO.File.Exists(avatarPath))
                    {
                        System.IO.File.Delete(avatarPath);
                    }
                    Session[AuthSessionKeys.AvatarVersion] = DateTime.UtcNow.Ticks;
                }
                catch (Exception exception) when (
                    exception is IOException ||
                    exception is UnauthorizedAccessException)
                {
                    TempData["Error"] = "Không thể xóa ảnh đại diện lúc này.";
                    return RedirectToAction("Profile");
                }

                db.AuditLogs.Add(new AuditLog
                {
                    UserID = userId,
                    ActionName = "REMOVE_AVATAR",
                    TableName = "Users",
                    RecordID = userId,
                    Description = "Ứng viên xóa ảnh đại diện.",
                    CreatedAt = DateTime.Now,
                    IpAddress = Request.UserHostAddress
                });
                db.SaveChanges();
            }

            TempData["Success"] = "Đã xóa ảnh đại diện.";
            return RedirectToAction("Profile");
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult ChangePassword(
            [Bind(Prefix = "Password")] CandidateChangePasswordViewModel model)
        {
            var userId = GetCurrentUserId();
            if (!ModelState.IsValid)
            {
                return ProfileViewWithModel(userId, null, model);
            }

            using (var db = new ATSMiniDBContext())
            {
                var user = db.Users.SingleOrDefault(u => u.UserID == userId && u.IsActive);
                if (user == null)
                {
                    return HttpNotFound();
                }

                if (!PasswordHashHelper.VerifyPassword(
                        user.PasswordSalt,
                        model.CurrentPassword,
                        user.PasswordHash))
                {
                    ModelState.AddModelError(
                        "Password.CurrentPassword",
                        "Mật khẩu hiện tại không chính xác.");
                    return ProfileViewWithModel(userId, null, model);
                }

                if (PasswordHashHelper.VerifyPassword(
                    user.PasswordSalt,
                    model.NewPassword,
                    user.PasswordHash))
                {
                    ModelState.AddModelError(
                        "Password.NewPassword",
                        "Mật khẩu mới phải khác mật khẩu hiện tại.");
                    return ProfileViewWithModel(userId, null, model);
                }

                var now = DateTime.Now;
                user.PasswordSalt = PasswordHashHelper.GenerateSalt();
                user.PasswordHash = PasswordHashHelper.HashPassword(
                    user.PasswordSalt,
                    model.NewPassword);
                user.FailedLoginCount = 0;
                user.LockedUntil = null;
                user.UpdatedAt = now;

                db.AuditLogs.Add(new AuditLog
                {
                    UserID = userId,
                    ActionName = "CHANGE_PASSWORD",
                    TableName = "Users",
                    RecordID = userId,
                    Description = "Ứng viên thay đổi mật khẩu.",
                    CreatedAt = now,
                    IpAddress = Request.UserHostAddress
                });

                try
                {
                    db.SaveChanges();
                }
                catch (DbUpdateException)
                {
                    ModelState.AddModelError(
                        string.Empty,
                        "Không thể đổi mật khẩu lúc này. Vui lòng thử lại.");
                    return ProfileViewWithModel(userId, null, model);
                }
            }

            TempData["Success"] = "Đổi mật khẩu thành công.";
            return RedirectToAction("Profile");
        }

        private ActionResult ProfileViewWithModel(
            int userId,
            CandidateProfileViewModel profile,
            CandidateChangePasswordViewModel password)
        {
            using (var db = new ATSMiniDBContext())
            {
                var page = BuildProfilePage(db, userId);
                if (page == null)
                {
                    return HttpNotFound();
                }

                if (profile != null)
                {
                    profile.Username = page.Profile.Username;
                    page.Profile = profile;
                }

                if (password != null)
                {
                    page.Password = password;
                }

                return View("Profile", page);
            }
        }

        private CandidateProfilePageViewModel BuildProfilePage(
            ATSMiniDBContext db,
            int userId)
        {
            var profile = db.Users
                .AsNoTracking()
                .Where(u => u.UserID == userId && u.IsActive)
                .Select(u => new CandidateProfileViewModel
                {
                    Username = u.Username,
                    FullName = u.FullName,
                    Email = u.Email,
                    Phone = u.Phone
                })
                .SingleOrDefault();
            if (profile == null)
            {
                return null;
            }

            var avatarPath = GetAvatarPhysicalPath(userId);
            var hasAvatar = System.IO.File.Exists(avatarPath);
            return new CandidateProfilePageViewModel
            {
                Profile = profile,
                Password = new CandidateChangePasswordViewModel(),
                HasAvatar = hasAvatar,
                AvatarUrl = hasAvatar
                    ? Url.Action("Avatar", "Candidate", new
                    {
                        v = System.IO.File.GetLastWriteTimeUtc(avatarPath).Ticks
                    })
                    : null
            };
        }

        private string GetAvatarPhysicalPath(int userId)
        {
            return Path.Combine(
                Server.MapPath("~/Uploads/Avatars"),
                "candidate-" + userId + ".jpg");
        }

        private int GetCurrentUserId()
        {
            return Convert.ToInt32(Session[AuthSessionKeys.UserID]);
        }
    }
}
