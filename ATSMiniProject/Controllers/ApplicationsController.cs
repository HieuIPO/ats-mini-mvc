using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Applications;

namespace ATSMiniProject.Controllers
{
    public class ApplicationsController : Controller
    {
        private const int AdminPageSize = 12;

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult Index(
            string keyword,
            int? jobId,
            int? statusId,
            DateTime? fromDate,
            DateTime? toDate,
            string queue = "attention",
            int page = 1)
        {
            page = Math.Max(page, 1);
            queue = NormalizeQueue(queue);
            var now = DateTime.Now;
            var today = now.Date;

            using (var db = new ATSMiniDBContext())
            {
                var query = db.Applications
                    .AsNoTracking()
                    .Where(a => !a.IsDeleted);

                if (!string.IsNullOrWhiteSpace(keyword))
                {
                    var value = keyword.Trim();
                    query = query.Where(a =>
                        a.CandidateName.Contains(value) ||
                        a.CandidateEmail.Contains(value) ||
                        a.CandidatePhone.Contains(value) ||
                        a.Job.Title.Contains(value));
                }

                if (jobId.HasValue)
                {
                    query = query.Where(a => a.JobID == jobId.Value);
                }

                if (fromDate.HasValue)
                {
                    var from = fromDate.Value.Date;
                    query = query.Where(a => a.AppliedDate >= from);
                }

                if (toDate.HasValue)
                {
                    var toExclusive = toDate.Value.Date.AddDays(1);
                    query = query.Where(a => a.AppliedDate < toExclusive);
                }

                var allCount = query.Count();
                var attentionCount = query.Count(a => !a.ApplicationStatus.IsFinal);
                var newCount = query.Count(a => a.ApplicationStatus.StatusName == "Mới nộp");
                var reviewingCount = query.Count(a => a.ApplicationStatus.StatusName == "Đang xem xét");
                var interviewCount = query.Count(a => a.ApplicationStatus.StatusName == "Mời phỏng vấn");
                var finalCount = query.Count(a => a.ApplicationStatus.IsFinal);

                if (statusId.HasValue)
                {
                    query = query.Where(a => a.StatusID == statusId.Value);
                }
                else if (queue == "attention")
                {
                    query = query.Where(a => !a.ApplicationStatus.IsFinal);
                }
                else if (queue == "new")
                {
                    query = query.Where(a => a.ApplicationStatus.StatusName == "Mới nộp");
                }
                else if (queue == "review")
                {
                    query = query.Where(a => a.ApplicationStatus.StatusName == "Đang xem xét");
                }
                else if (queue == "interview")
                {
                    query = query.Where(a => a.ApplicationStatus.StatusName == "Mời phỏng vấn");
                }
                else if (queue == "final")
                {
                    query = query.Where(a => a.ApplicationStatus.IsFinal);
                }

                var totalItems = query.Count();
                var totalPages = Math.Max(1, (int)Math.Ceiling(totalItems / (double)AdminPageSize));
                page = Math.Min(page, totalPages);

                var orderedQuery = queue == "attention" && !statusId.HasValue
                    ? query
                        .OrderBy(a => a.ApplicationStatus.StatusName == "Mới nộp" ? 0 :
                                      a.ApplicationStatus.StatusName == "Đang xem xét" ? 1 :
                                      a.ApplicationStatus.StatusName == "Mời phỏng vấn" ? 2 : 3)
                        .ThenBy(a => a.AppliedDate)
                        .ThenBy(a => a.ApplicationID)
                    : query
                        .OrderByDescending(a => a.AppliedDate)
                        .ThenByDescending(a => a.ApplicationID);

                var applications = orderedQuery
                    .Skip((page - 1) * AdminPageSize)
                    .Take(AdminPageSize)
                    .Select(a => new AdminApplicationListItemViewModel
                    {
                        ApplicationId = a.ApplicationID,
                        CandidateUserId = a.CandidateUserID,
                        CandidateName = a.CandidateName,
                        CandidateEmail = a.CandidateEmail,
                        CandidatePhone = a.CandidatePhone,
                        JobTitle = a.Job.Title,
                        DepartmentName = a.Job.Department.DepartmentName,
                        StatusName = a.ApplicationStatus.StatusName,
                        IsFinal = a.ApplicationStatus.IsFinal,
                        AppliedDate = a.AppliedDate,
                        WaitingDays = DbFunctions.DiffDays(a.AppliedDate, now) ?? 0,
                        NextInterviewDate = a.Interviews
                            .Where(i => !i.IsDeleted && i.InterviewDate >= now)
                            .OrderBy(i => i.InterviewDate)
                            .Select(i => (DateTime?)i.InterviewDate)
                            .FirstOrDefault()
                    })
                    .ToList();

                var jobs = db.Jobs
                    .AsNoTracking()
                    .Where(j => !j.IsDeleted)
                    .OrderByDescending(j => j.IsActive && (!j.Deadline.HasValue || j.Deadline.Value >= today))
                    .ThenBy(j => j.Deadline.HasValue && j.Deadline.Value < today)
                    .ThenBy(j => j.Title)
                    .Select(j => new { j.JobID, j.Title, j.IsActive, j.Deadline })
                    .ToList()
                    .Select(j =>
                    {
                        var isExpired = j.Deadline.HasValue && j.Deadline.Value.Date < today;
                        var statusLabel = isExpired
                            ? "🟠 Hết hạn"
                            : j.IsActive ? "🟢 Đang tuyển" : "🔴 Đã đóng";

                        return new SelectListItem
                        {
                            Value = j.JobID.ToString(),
                            Text = j.Title + " — " + statusLabel,
                            Selected = jobId.HasValue && j.JobID == jobId.Value
                        };
                    })
                    .ToList();

                foreach (var application in applications)
                {
                    var avatarPath = GetCandidateAvatarPhysicalPath(application.CandidateUserId);
                    if (!string.IsNullOrWhiteSpace(avatarPath) && System.IO.File.Exists(avatarPath))
                    {
                        application.CandidateAvatarUrl = Url.Action(
                            "CandidateAvatar",
                            "Applications",
                            new
                            {
                                id = application.ApplicationId,
                                v = System.IO.File.GetLastWriteTimeUtc(avatarPath).Ticks
                            });
                    }
                }

                var statuses = db.ApplicationStatuses
                    .AsNoTracking()
                    .OrderBy(s => s.DisplayOrder)
                    .Select(s => new { s.StatusID, s.StatusName })
                    .ToList()
                    .Select(s => new SelectListItem
                    {
                        Value = s.StatusID.ToString(),
                        Text = s.StatusName,
                        Selected = statusId.HasValue && s.StatusID == statusId.Value
                    })
                    .ToList();

                return View(new AdminApplicationListViewModel
                {
                    Keyword = keyword,
                    JobId = jobId,
                    StatusId = statusId,
                    FromDate = fromDate,
                    ToDate = toDate,
                    Queue = queue,
                    Page = page,
                    TotalPages = totalPages,
                    TotalItems = totalItems,
                    AttentionCount = attentionCount,
                    NewCount = newCount,
                    ReviewingCount = reviewingCount,
                    InterviewCount = interviewCount,
                    FinalCount = finalCount,
                    AllCount = allCount,
                    Applications = applications,
                    Jobs = jobs,
                    Statuses = statuses
                });
            }
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult CandidateAvatar(int id)
        {
            int? candidateUserId;
            using (var db = new ATSMiniDBContext())
            {
                candidateUserId = db.Applications
                    .AsNoTracking()
                    .Where(a =>
                        a.ApplicationID == id && !a.IsDeleted &&
                        a.CandidateUserID.HasValue &&
                        a.User.Role.RoleName == "Candidate")
                    .Select(a => a.CandidateUserID)
                    .SingleOrDefault();
            }

            var avatarPath = GetCandidateAvatarPhysicalPath(candidateUserId);
            if (string.IsNullOrWhiteSpace(avatarPath) || !System.IO.File.Exists(avatarPath))
            {
                return HttpNotFound();
            }

            Response.Cache.SetCacheability(System.Web.HttpCacheability.Private);
            Response.Cache.SetMaxAge(TimeSpan.FromDays(1));
            return File(avatarPath, "image/jpeg");
        }

        private string GetCandidateAvatarPhysicalPath(int? candidateUserId)
        {
            if (!candidateUserId.HasValue)
            {
                return null;
            }

            return Path.Combine(
                Server.MapPath("~/Uploads/Avatars"),
                "candidate-" + candidateUserId.Value + ".jpg");
        }

        private static string NormalizeQueue(string queue)
        {
            var value = string.IsNullOrWhiteSpace(queue)
                ? "attention"
                : queue.Trim().ToLowerInvariant();

            return value == "new" ||
                   value == "review" ||
                   value == "interview" ||
                   value == "final" ||
                   value == "all"
                ? value
                : "attention";
        }

        [AuthorizeRole("Candidate")]
        [HttpGet]
        public ActionResult Status()
        {
            var userId = GetCurrentUserId();
            var now = DateTime.Now;

            using (var db = new ATSMiniDBContext())
            {
                var applications = db.Applications
                    .AsNoTracking()
                    .Where(a => a.CandidateUserID == userId && !a.IsDeleted)
                    .OrderByDescending(a => a.AppliedDate)
                    .Select(a => new CandidateApplicationItemViewModel
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

                return View(new CandidateApplicationListViewModel
                {
                    Applications = applications
                });
            }
        }

        [AuthorizeRole("Candidate")]
        [HttpGet]
        public ActionResult Details(int id)
        {
            var userId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            {
                var application = db.Applications
                    .AsNoTracking()
                    .Include(a => a.Job.Department)
                    .Include(a => a.Job.JobPosition)
                    .Include(a => a.ApplicationStatus)
                    .Include(a => a.CandidateFiles)
                    .Include(a => a.ApplicationStatusHistories.Select(h => h.ApplicationStatus1))
                    .Include(a => a.Interviews)
                    .SingleOrDefault(a => a.ApplicationID == id &&
                                          a.CandidateUserID == userId &&
                                          !a.IsDeleted);

                if (application == null)
                {
                    return HttpNotFound();
                }

                var candidateFile = application.CandidateFiles
                    .Where(f => !f.IsDeleted)
                    .OrderByDescending(f => f.UploadedAt)
                    .FirstOrDefault();
                var candidateFilePath = candidateFile == null
                    ? null
                    : ResolveCandidateFilePath(candidateFile.FilePath);
                var hasDownloadableFile = candidateFilePath != null &&
                                          System.IO.File.Exists(candidateFilePath);

                var model = new CandidateApplicationDetailsViewModel
                {
                    ApplicationId = application.ApplicationID,
                    JobId = application.JobID,
                    JobTitle = application.Job.Title,
                    DepartmentName = application.Job.Department.DepartmentName,
                    PositionName = application.Job.JobPosition.PositionName,
                    Location = application.Job.Location,
                    StatusName = application.ApplicationStatus.StatusName,
                    IsFinal = application.ApplicationStatus.IsFinal,
                    AppliedDate = application.AppliedDate,
                    CandidateName = application.CandidateName,
                    CandidateEmail = application.CandidateEmail,
                    CandidatePhone = application.CandidatePhone,
                    CandidateFileId = hasDownloadableFile ? (int?)candidateFile.CandidateFileID : null,
                    CvOriginalFileName = hasDownloadableFile ? candidateFile.OriginalFileName : null,
                    StatusHistory = application.ApplicationStatusHistories
                        .OrderByDescending(h => h.ChangedAt)
                        .Select(h => new CandidateStatusHistoryViewModel
                        {
                            StatusName = h.ApplicationStatus1.StatusName,
                            ChangedAt = h.ChangedAt
                        })
                        .ToList(),
                    Interviews = application.Interviews
                        .Where(i => !i.IsDeleted)
                        .OrderBy(i => i.InterviewDate)
                        .Select(i => new CandidateInterviewViewModel
                        {
                            InterviewId = i.InterviewID,
                            InterviewDate = i.InterviewDate,
                            Location = i.InterviewLocation,
                            Result = i.Result,
                            CanAddToCalendar = i.InterviewDate >= DateTime.Now
                        })
                        .ToList()
                };

                model.NextInterviewDate = model.Interviews
                    .Where(i => i.InterviewDate >= DateTime.Now)
                    .Select(i => (DateTime?)i.InterviewDate)
                    .FirstOrDefault();

                return View(model);
            }
        }

        [AuthorizeRole("Candidate")]
        [HttpGet]
        public ActionResult DownloadCv(int id)
        {
            var userId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            {
                var candidateFile = db.CandidateFiles
                    .AsNoTracking()
                    .SingleOrDefault(f => f.CandidateFileID == id &&
                                          !f.IsDeleted &&
                                          !f.Application.IsDeleted &&
                                          f.Application.CandidateUserID == userId);
                if (candidateFile == null)
                {
                    return HttpNotFound();
                }

                var candidatePath = ResolveCandidateFilePath(candidateFile.FilePath);
                if (candidatePath == null || !System.IO.File.Exists(candidatePath))
                {
                    return HttpNotFound();
                }

                return File(candidatePath, GetContentType(candidateFile.FileExtension), candidateFile.OriginalFileName);
            }
        }

        [AuthorizeRole("Candidate")]
        [HttpGet]
        public ActionResult DownloadInterviewCalendar(int id)
        {
            var userId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            {
                var interview = db.Interviews
                    .AsNoTracking()
                    .Where(i => i.InterviewID == id &&
                                !i.IsDeleted &&
                                !i.Application.IsDeleted &&
                                i.Application.CandidateUserID == userId)
                    .Select(i => new
                    {
                        i.InterviewID,
                        i.InterviewDate,
                        i.InterviewLocation,
                        i.ApplicationID,
                        JobTitle = i.Application.Job.Title,
                        DepartmentName = i.Application.Job.Department.DepartmentName
                    })
                    .SingleOrDefault();
                if (interview == null)
                {
                    return HttpNotFound();
                }

                var vietnamTimeZone = TimeZoneInfo.FindSystemTimeZoneById(
                    "SE Asia Standard Time");
                var localStart = DateTime.SpecifyKind(
                    interview.InterviewDate,
                    DateTimeKind.Unspecified);
                var startUtc = TimeZoneInfo.ConvertTimeToUtc(
                    localStart,
                    vietnamTimeZone);
                var endUtc = startUtc.AddHours(1);
                var detailsUrl = Url.Action(
                    "Details",
                    "Applications",
                    new { id = interview.ApplicationID },
                    Request.Url == null ? "https" : Request.Url.Scheme);
                var description = string.Join(
                    "\n",
                    "Vị trí: " + interview.JobTitle,
                    "Phòng ban: " + interview.DepartmentName,
                    "Theo dõi hồ sơ: " + detailsUrl);
                var calendar = string.Join("\r\n", new[]
                {
                    "BEGIN:VCALENDAR",
                    "VERSION:2.0",
                    "PRODID:-//ATS Careers//Candidate Interview//VI",
                    "CALSCALE:GREGORIAN",
                    "METHOD:PUBLISH",
                    "BEGIN:VEVENT",
                    "UID:interview-" + interview.InterviewID + "@ats-careers.local",
                    "DTSTAMP:" + DateTime.UtcNow.ToString("yyyyMMdd'T'HHmmss'Z'"),
                    "DTSTART:" + startUtc.ToString("yyyyMMdd'T'HHmmss'Z'"),
                    "DTEND:" + endUtc.ToString("yyyyMMdd'T'HHmmss'Z'"),
                    "SUMMARY:" + EscapeCalendarText("Phỏng vấn - " + interview.JobTitle),
                    "LOCATION:" + EscapeCalendarText(
                        interview.InterviewLocation ?? "Sẽ được cập nhật"),
                    "DESCRIPTION:" + EscapeCalendarText(description),
                    "URL:" + EscapeCalendarText(detailsUrl),
                    "BEGIN:VALARM",
                    "TRIGGER:-PT30M",
                    "ACTION:DISPLAY",
                    "DESCRIPTION:Nhắc lịch phỏng vấn",
                    "END:VALARM",
                    "END:VEVENT",
                    "END:VCALENDAR",
                    string.Empty
                });

                return File(
                    new UTF8Encoding(true).GetBytes(calendar),
                    "text/calendar; charset=utf-8",
                    "lich-phong-van-" + interview.InterviewID + ".ics");
            }
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult Review(int id)
        {
            using (var db = new ATSMiniDBContext())
            {
                var application = db.Applications
                    .AsNoTracking()
                    .Include(a => a.Job.Department)
                    .Include(a => a.Job.JobPosition)
                    .Include(a => a.ApplicationStatus)
                    .Include(a => a.CandidateFiles)
                    .Include(a => a.ApplicationStatusHistories.Select(h => h.ApplicationStatus))
                    .Include(a => a.ApplicationStatusHistories.Select(h => h.ApplicationStatus1))
                    .Include(a => a.ApplicationStatusHistories.Select(h => h.User))
                    .Include(a => a.Interviews.Select(i => i.User))
                    .SingleOrDefault(a => a.ApplicationID == id && !a.IsDeleted);

                if (application == null)
                {
                    return HttpNotFound();
                }

                var candidateFile = application.CandidateFiles
                    .Where(f => !f.IsDeleted)
                    .OrderByDescending(f => f.UploadedAt)
                    .FirstOrDefault();
                var candidateFilePath = candidateFile == null
                    ? null
                    : ResolveCandidateFilePath(candidateFile.FilePath);
                var hasDownloadableFile = candidateFilePath != null &&
                                          System.IO.File.Exists(candidateFilePath);

                var statusOptions = db.ApplicationStatuses
                    .AsNoTracking()
                    .OrderBy(s => s.DisplayOrder)
                    .Select(s => new { s.StatusID, s.StatusName })
                    .ToList()
                    .Select(s => new SelectListItem
                    {
                        Value = s.StatusID.ToString(),
                        Text = s.StatusName,
                        Selected = s.StatusID == application.StatusID
                    })
                    .ToList();

                var model = new AdminApplicationDetailsViewModel
                {
                    ApplicationId = application.ApplicationID,
                    JobId = application.JobID,
                    JobTitle = application.Job.Title,
                    DepartmentName = application.Job.Department.DepartmentName,
                    PositionName = application.Job.JobPosition.PositionName,
                    CandidateName = application.CandidateName,
                    CandidateEmail = application.CandidateEmail,
                    CandidatePhone = application.CandidatePhone,
                    StatusName = application.ApplicationStatus.StatusName,
                    StatusId = application.StatusID,
                    IsFinal = application.ApplicationStatus.IsFinal,
                    AppliedDate = application.AppliedDate,
                    HRNote = application.HRNote,
                    CandidateFileId = hasDownloadableFile ? (int?)candidateFile.CandidateFileID : null,
                    CvOriginalFileName = hasDownloadableFile ? candidateFile.OriginalFileName : null,
                    StatusOptions = statusOptions,
                    StatusHistory = application.ApplicationStatusHistories
                        .OrderByDescending(h => h.ChangedAt)
                        .Select(h => new AdminStatusHistoryItemViewModel
                        {
                            OldStatusName = h.ApplicationStatus == null
                                ? null
                                : h.ApplicationStatus.StatusName,
                            NewStatusName = h.ApplicationStatus1.StatusName,
                            ChangedByName = h.User == null ? "Hệ thống" : h.User.FullName,
                            ChangedAt = h.ChangedAt,
                            Note = h.Note
                        })
                        .ToList(),
                    Interviews = application.Interviews
                        .Where(i => !i.IsDeleted)
                        .OrderByDescending(i => i.InterviewDate)
                        .Select(i => new AdminApplicationInterviewItemViewModel
                        {
                            InterviewId = i.InterviewID,
                            InterviewDate = i.InterviewDate,
                            Location = i.InterviewLocation,
                            InterviewerName = i.User == null ? "Chưa phân công" : i.User.FullName,
                            Result = i.Result
                        })
                        .ToList()
                };

                return View(model);
            }
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult UpdateStatus(UpdateApplicationStatusViewModel model)
        {
            if (!ModelState.IsValid)
            {
                TempData["Error"] = "Dữ liệu cập nhật trạng thái chưa hợp lệ.";
                return RedirectToAction("Review", new { id = model.ApplicationId });
            }

            var currentUserId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            using (var transaction = db.Database.BeginTransaction())
            {
                try
                {
                    var application = db.Applications
                        .Include(a => a.ApplicationStatus)
                        .SingleOrDefault(a => a.ApplicationID == model.ApplicationId && !a.IsDeleted);
                    var newStatus = db.ApplicationStatuses
                        .SingleOrDefault(s => s.StatusID == model.StatusId);

                    if (application == null || newStatus == null)
                    {
                        transaction.Rollback();
                        return HttpNotFound();
                    }

                    var normalizedHrNote = string.IsNullOrWhiteSpace(model.HRNote)
                        ? null
                        : model.HRNote.Trim();
                    var statusChanged = application.StatusID != newStatus.StatusID;
                    var noteChanged = !string.Equals(
                        application.HRNote ?? string.Empty,
                        normalizedHrNote ?? string.Empty,
                        StringComparison.Ordinal);

                    if (!statusChanged && !noteChanged)
                    {
                        transaction.Rollback();
                        TempData["Success"] = "Hồ sơ không có thay đổi mới.";
                        return RedirectToAction("Review", new { id = model.ApplicationId });
                    }

                    var oldStatusId = application.StatusID;
                    var oldStatusName = application.ApplicationStatus.StatusName;
                    var now = DateTime.Now;

                    application.HRNote = normalizedHrNote;
                    application.UpdatedAt = now;
                    application.UpdatedByUserID = currentUserId;

                    if (statusChanged)
                    {
                        application.StatusID = newStatus.StatusID;
                        db.ApplicationStatusHistories.Add(new ApplicationStatusHistory
                        {
                            ApplicationID = application.ApplicationID,
                            OldStatusID = oldStatusId,
                            NewStatusID = newStatus.StatusID,
                            ChangedByUserID = currentUserId,
                            ChangedAt = now,
                            Note = string.IsNullOrWhiteSpace(model.StatusNote)
                                ? "HR cập nhật trạng thái hồ sơ."
                                : model.StatusNote.Trim()
                        });
                    }

                    db.AuditLogs.Add(new AuditLog
                    {
                        UserID = currentUserId,
                        ActionName = statusChanged ? "UPDATE_APPLICATION_STATUS" : "UPDATE_APPLICATION_NOTE",
                        TableName = "Applications",
                        RecordID = application.ApplicationID,
                        Description = statusChanged
                            ? "Cập nhật trạng thái từ " + oldStatusName + " sang " + newStatus.StatusName + "."
                            : "Cập nhật ghi chú nội bộ của hồ sơ.",
                        CreatedAt = now,
                        IpAddress = Request.UserHostAddress
                    });

                    db.SaveChanges();
                    transaction.Commit();
                    TempData["Success"] = statusChanged
                        ? "Cập nhật trạng thái hồ sơ thành công."
                        : "Cập nhật ghi chú nội bộ thành công.";
                }
                catch (DbUpdateException)
                {
                    transaction.Rollback();
                    TempData["Error"] = "Không thể cập nhật hồ sơ vì dữ liệu vừa thay đổi.";
                }
            }

            return RedirectToAction("Review", new { id = model.ApplicationId });
        }

        [AuthorizeRole("Admin", "HR")]
        [HttpGet]
        public ActionResult DownloadCandidateCv(int id)
        {
            using (var db = new ATSMiniDBContext())
            {
                var candidateFile = db.CandidateFiles
                    .AsNoTracking()
                    .SingleOrDefault(f => f.CandidateFileID == id &&
                                          !f.IsDeleted &&
                                          !f.Application.IsDeleted);
                if (candidateFile == null)
                {
                    return HttpNotFound();
                }

                var candidatePath = ResolveCandidateFilePath(candidateFile.FilePath);
                if (candidatePath == null || !System.IO.File.Exists(candidatePath))
                {
                    return HttpNotFound();
                }

                return File(candidatePath, GetContentType(candidateFile.FileExtension), candidateFile.OriginalFileName);
            }
        }

        private int GetCurrentUserId()
        {
            return Convert.ToInt32(Session[AuthSessionKeys.UserID]);
        }

        private string ResolveCandidateFilePath(string relativePath)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
            {
                return null;
            }

            try
            {
                var uploadRoot = Path.GetFullPath(Server.MapPath("~/Uploads/CVs"));
                var candidatePath = Path.GetFullPath(
                    Server.MapPath("~/" + relativePath.TrimStart('/', '\\')));
                var allowedPrefix = uploadRoot.TrimEnd(Path.DirectorySeparatorChar) +
                                    Path.DirectorySeparatorChar;

                return candidatePath.StartsWith(allowedPrefix, StringComparison.OrdinalIgnoreCase)
                    ? candidatePath
                    : null;
            }
            catch (Exception exception) when (
                exception is ArgumentException ||
                exception is NotSupportedException ||
                exception is PathTooLongException)
            {
                return null;
            }
        }

        private static string GetContentType(string extension)
        {
            switch ((extension ?? string.Empty).ToLowerInvariant())
            {
                case ".pdf":
                    return "application/pdf";
                case ".doc":
                    return "application/msword";
                case ".docx":
                    return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                default:
                    return "application/octet-stream";
            }
        }

        private static string EscapeCalendarText(string value)
        {
            return (value ?? string.Empty)
                .Replace("\\", "\\\\")
                .Replace("\r\n", "\\n")
                .Replace("\n", "\\n")
                .Replace(",", "\\,")
                .Replace(";", "\\;");
        }
    }
}
