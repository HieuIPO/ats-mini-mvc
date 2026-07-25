using System;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Interviews;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Admin", "HR")]
    public class InterviewsController : Controller
    {
        private const int PageSize = 12;

        private static readonly string[] InterviewResults =
        {
            "Chưa có kết quả",
            "Đạt",
            "Không đạt",
            "Ứng viên không tham gia"
        };

        [HttpGet]
        public ActionResult Index(
            string keyword,
            string result,
            DateTime? fromDate,
            DateTime? toDate,
            int page = 1)
        {
            page = Math.Max(page, 1);
            var now = DateTime.Now;

            using (var db = new ATSMiniDBContext())
            {
                var query = db.Interviews
                    .AsNoTracking()
                    .Where(i => !i.IsDeleted && !i.Application.IsDeleted);

                if (!string.IsNullOrWhiteSpace(keyword))
                {
                    var value = keyword.Trim();
                    query = query.Where(i =>
                        i.Application.CandidateName.Contains(value) ||
                        i.Application.CandidateEmail.Contains(value) ||
                        i.Application.Job.Title.Contains(value) ||
                        (i.InterviewLocation != null && i.InterviewLocation.Contains(value)));
                }

                if (!string.IsNullOrWhiteSpace(result))
                {
                    var value = result.Trim();
                    query = query.Where(i => i.Result == value);
                }

                if (fromDate.HasValue)
                {
                    var from = fromDate.Value.Date;
                    query = query.Where(i => i.InterviewDate >= from);
                }

                if (toDate.HasValue)
                {
                    var toExclusive = toDate.Value.Date.AddDays(1);
                    query = query.Where(i => i.InterviewDate < toExclusive);
                }

                var totalItems = query.Count();
                var totalPages = Math.Max(1, (int)Math.Ceiling(totalItems / (double)PageSize));
                page = Math.Min(page, totalPages);

                var interviews = query
                    .OrderByDescending(i => i.InterviewDate)
                    .ThenByDescending(i => i.InterviewID)
                    .Skip((page - 1) * PageSize)
                    .Take(PageSize)
                    .Select(i => new InterviewListItemViewModel
                    {
                        InterviewId = i.InterviewID,
                        ApplicationId = i.ApplicationID,
                        CandidateName = i.Application.CandidateName,
                        JobTitle = i.Application.Job.Title,
                        InterviewDate = i.InterviewDate,
                        Location = i.InterviewLocation,
                        InterviewerName = i.User == null ? "Chưa phân công" : i.User.FullName,
                        Result = i.Result,
                        IsUpcoming = i.InterviewDate >= now
                    })
                    .ToList();

                return View(new InterviewListViewModel
                {
                    Keyword = keyword,
                    Result = result,
                    FromDate = fromDate,
                    ToDate = toDate,
                    Page = page,
                    TotalPages = totalPages,
                    TotalItems = totalItems,
                    Interviews = interviews,
                    ResultOptions = BuildResultOptions(result)
                });
            }
        }

        [HttpGet]
        public ActionResult Create(int? applicationId)
        {
            using (var db = new ATSMiniDBContext())
            {
                var model = new InterviewEditViewModel
                {
                    ApplicationId = applicationId ?? 0,
                    InterviewDate = DateTime.Now.Date.AddDays(1).AddHours(9),
                    Result = InterviewResults[0]
                };

                if (applicationId.HasValue)
                {
                    var selectedApplication = db.Applications
                        .AsNoTracking()
                        .Where(a => a.ApplicationID == applicationId.Value && !a.IsDeleted)
                        .Select(a => new
                        {
                            a.ApplicationID,
                            a.ApplicationStatus.IsFinal
                        })
                        .SingleOrDefault();
                    if (selectedApplication == null)
                    {
                        return HttpNotFound();
                    }

                    if (selectedApplication.IsFinal)
                    {
                        TempData["Error"] = "Hồ sơ đã kết thúc. Hãy mở lại trạng thái trước khi tạo lịch mới.";
                        return RedirectToAction(
                            "Review",
                            "Applications",
                            new { id = selectedApplication.ApplicationID });
                    }
                }

                PopulateEditorOptions(db, model);
                return View("Edit", model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create(InterviewEditViewModel model)
        {
            ValidateInterviewInput(model, true);

            using (var db = new ATSMiniDBContext())
            {
                var application = db.Applications
                    .Include(a => a.ApplicationStatus)
                    .SingleOrDefault(a => a.ApplicationID == model.ApplicationId && !a.IsDeleted);
                if (application != null && application.ApplicationStatus.IsFinal)
                {
                    ModelState.AddModelError(
                        "ApplicationId",
                        "Hồ sơ đã kết thúc. Hãy mở lại trạng thái hồ sơ trước khi tạo lịch mới.");
                }
                ValidateReferences(db, model, application, null);

                if (!ModelState.IsValid)
                {
                    PopulateEditorOptions(db, model);
                    return View("Edit", model);
                }

                var currentUserId = GetCurrentUserId();
                var now = DateTime.Now;

                using (var transaction = db.Database.BeginTransaction())
                {
                    try
                    {
                        var interview = new Interview
                        {
                            ApplicationID = application.ApplicationID,
                            InterviewDate = model.InterviewDate,
                            InterviewLocation = Normalize(model.InterviewLocation),
                            InterviewerUserID = model.InterviewerUserId,
                            Note = Normalize(model.Note),
                            Result = NormalizeResult(model.Result),
                            CreatedAt = now,
                            CreatedByUserID = currentUserId,
                            IsDeleted = false
                        };
                        db.Interviews.Add(interview);

                        var interviewStatus = db.ApplicationStatuses
                            .OrderBy(s => s.DisplayOrder)
                            .FirstOrDefault(s => s.StatusName == "Mời phỏng vấn");
                        if (interviewStatus != null &&
                            !application.ApplicationStatus.IsFinal &&
                            application.StatusID != interviewStatus.StatusID)
                        {
                            ChangeApplicationStatus(
                                db,
                                application,
                                interviewStatus,
                                currentUserId,
                                "Tự động chuyển trạng thái khi HR tạo lịch phỏng vấn.",
                                now);
                        }

                        SyncApplicationStatusFromResult(
                            db,
                            application,
                            interview.Result,
                            currentUserId,
                            now);
                        application.UpdatedAt = now;
                        application.UpdatedByUserID = currentUserId;
                        db.SaveChanges();

                        db.AuditLogs.Add(new AuditLog
                        {
                            UserID = currentUserId,
                            ActionName = "CREATE_INTERVIEW",
                            TableName = "Interviews",
                            RecordID = interview.InterviewID,
                            Description = "Tạo lịch phỏng vấn cho hồ sơ #" + application.ApplicationID + ".",
                            CreatedAt = now,
                            IpAddress = Request.UserHostAddress
                        });
                        db.SaveChanges();
                        transaction.Commit();

                        TempData["Success"] = "Tạo lịch phỏng vấn thành công.";
                        return RedirectToAction("Edit", new { id = interview.InterviewID });
                    }
                    catch (DbUpdateException)
                    {
                        transaction.Rollback();
                        ModelState.AddModelError(string.Empty, "Không thể tạo lịch vì dữ liệu vừa thay đổi.");
                    }
                }

                PopulateEditorOptions(db, model);
                return View("Edit", model);
            }
        }

        [HttpGet]
        public ActionResult Edit(int id)
        {
            using (var db = new ATSMiniDBContext())
            {
                var model = db.Interviews
                    .AsNoTracking()
                    .Where(i => i.InterviewID == id && !i.IsDeleted && !i.Application.IsDeleted)
                    .Select(i => new InterviewEditViewModel
                    {
                        InterviewId = i.InterviewID,
                        ApplicationId = i.ApplicationID,
                        InterviewDate = i.InterviewDate,
                        InterviewLocation = i.InterviewLocation,
                        InterviewerUserId = i.InterviewerUserID,
                        Note = i.Note,
                        Result = i.Result,
                        CandidateName = i.Application.CandidateName,
                        JobTitle = i.Application.Job.Title
                    })
                    .SingleOrDefault();

                if (model == null)
                {
                    return HttpNotFound();
                }

                PopulateEditorOptions(db, model);
                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit(InterviewEditViewModel model)
        {
            if (!model.InterviewId.HasValue)
            {
                return HttpNotFound();
            }

            ValidateInterviewInput(model, false);

            using (var db = new ATSMiniDBContext())
            {
                var interview = db.Interviews
                    .Include(i => i.Application.ApplicationStatus)
                    .SingleOrDefault(i => i.InterviewID == model.InterviewId.Value &&
                                          !i.IsDeleted &&
                                          !i.Application.IsDeleted);
                if (interview == null)
                {
                    return HttpNotFound();
                }

                model.ApplicationId = interview.ApplicationID;
                ValidateReferences(db, model, interview.Application, interview.InterviewID);

                if (!ModelState.IsValid)
                {
                    PopulateEditorOptions(db, model);
                    return View(model);
                }

                var currentUserId = GetCurrentUserId();
                var now = DateTime.Now;

                using (var transaction = db.Database.BeginTransaction())
                {
                    try
                    {
                        var previousResult = NormalizeResult(interview.Result);
                        interview.InterviewDate = model.InterviewDate;
                        interview.InterviewLocation = Normalize(model.InterviewLocation);
                        interview.InterviewerUserID = model.InterviewerUserId;
                        interview.Note = Normalize(model.Note);
                        interview.Result = NormalizeResult(model.Result);
                        interview.UpdatedAt = now;
                        interview.UpdatedByUserID = currentUserId;

                        SyncApplicationStatusFromResult(
                            db,
                            interview.Application,
                            interview.Result,
                            currentUserId,
                            now);
                        if (IsFinalResult(previousResult) &&
                            !IsFinalResult(interview.Result) &&
                            string.Equals(
                                interview.Application.ApplicationStatus.StatusName,
                                previousResult,
                                StringComparison.Ordinal))
                        {
                            ReconcileApplicationStatus(
                                db,
                                interview.Application,
                                interview.InterviewID,
                                true,
                                currentUserId,
                                now,
                                "Tự động đối soát trạng thái khi kết quả phỏng vấn được thay đổi.");
                        }
                        interview.Application.UpdatedAt = now;
                        interview.Application.UpdatedByUserID = currentUserId;

                        db.AuditLogs.Add(new AuditLog
                        {
                            UserID = currentUserId,
                            ActionName = "UPDATE_INTERVIEW",
                            TableName = "Interviews",
                            RecordID = interview.InterviewID,
                            Description = "Cập nhật lịch hoặc kết quả phỏng vấn.",
                            CreatedAt = now,
                            IpAddress = Request.UserHostAddress
                        });

                        db.SaveChanges();
                        transaction.Commit();
                        TempData["Success"] = "Cập nhật lịch phỏng vấn thành công.";
                        return RedirectToAction("Edit", new { id = interview.InterviewID });
                    }
                    catch (DbUpdateException)
                    {
                        transaction.Rollback();
                        ModelState.AddModelError(string.Empty, "Không thể cập nhật lịch vì dữ liệu vừa thay đổi.");
                    }
                }

                PopulateEditorOptions(db, model);
                return View(model);
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Cancel(int id)
        {
            var currentUserId = GetCurrentUserId();

            using (var db = new ATSMiniDBContext())
            {
                var interview = db.Interviews
                    .Include(i => i.Application.ApplicationStatus)
                    .SingleOrDefault(i => i.InterviewID == id &&
                                          !i.IsDeleted &&
                                          !i.Application.IsDeleted);
                if (interview == null)
                {
                    return HttpNotFound();
                }

                var now = DateTime.Now;
                interview.IsDeleted = true;
                interview.UpdatedAt = now;
                interview.UpdatedByUserID = currentUserId;

                var currentStatusName = interview.Application.ApplicationStatus.StatusName;
                if (string.Equals(currentStatusName, "Mời phỏng vấn", StringComparison.Ordinal) ||
                    (IsFinalResult(interview.Result) &&
                     string.Equals(currentStatusName, interview.Result, StringComparison.Ordinal)))
                {
                    ReconcileApplicationStatus(
                        db,
                        interview.Application,
                        interview.InterviewID,
                        false,
                        currentUserId,
                        now,
                        "Tự động đối soát trạng thái khi lịch phỏng vấn bị hủy.");
                    interview.Application.UpdatedAt = now;
                    interview.Application.UpdatedByUserID = currentUserId;
                }

                db.AuditLogs.Add(new AuditLog
                {
                    UserID = currentUserId,
                    ActionName = "CANCEL_INTERVIEW",
                    TableName = "Interviews",
                    RecordID = interview.InterviewID,
                    Description = "Hủy lịch phỏng vấn của hồ sơ #" + interview.ApplicationID + ".",
                    CreatedAt = now,
                    IpAddress = Request.UserHostAddress
                });

                try
                {
                    db.SaveChanges();
                    TempData["Success"] = "Đã hủy lịch phỏng vấn.";
                }
                catch (DbUpdateException)
                {
                    TempData["Error"] = "Không thể hủy lịch vì dữ liệu vừa thay đổi.";
                }
            }

            return RedirectToAction("Index");
        }

        private void ValidateInterviewInput(InterviewEditViewModel model, bool isCreate)
        {
            if (isCreate && model.InterviewDate <= DateTime.Now)
            {
                ModelState.AddModelError("InterviewDate", "Lịch phỏng vấn mới phải ở thời điểm tương lai.");
            }

            var result = NormalizeResult(model.Result);
            if (!InterviewResults.Contains(result))
            {
                ModelState.AddModelError("Result", "Kết quả phỏng vấn không hợp lệ.");
            }
            else if (isCreate && !string.Equals(
                         result,
                         InterviewResults[0],
                         StringComparison.Ordinal))
            {
                ModelState.AddModelError(
                    "Result",
                    "Kết quả chỉ được cập nhật sau khi lịch phỏng vấn đã được tạo.");
            }
        }

        private void ValidateReferences(
            ATSMiniDBContext db,
            InterviewEditViewModel model,
            Application application,
            int? currentInterviewId)
        {
            if (application == null)
            {
                ModelState.AddModelError("ApplicationId", "Hồ sơ ứng viên không tồn tại.");
            }

            if (model.InterviewerUserId.HasValue)
            {
                var interviewerIsValid = db.Users.Any(u =>
                    u.UserID == model.InterviewerUserId.Value &&
                    u.IsActive &&
                    u.Role.IsActive &&
                    (u.Role.RoleName == "Admin" || u.Role.RoleName == "HR"));
                if (!interviewerIsValid)
                {
                    ModelState.AddModelError("InterviewerUserId", "Người phỏng vấn không hợp lệ.");
                }
            }

            if (application != null)
            {
                var duplicateExists = db.Interviews.Any(i =>
                    !i.IsDeleted &&
                    i.ApplicationID == application.ApplicationID &&
                    i.InterviewDate == model.InterviewDate &&
                    (!currentInterviewId.HasValue || i.InterviewID != currentInterviewId.Value));
                if (duplicateExists)
                {
                    ModelState.AddModelError("InterviewDate", "Hồ sơ đã có lịch phỏng vấn tại thời điểm này.");
                }
            }
        }

        private static void ChangeApplicationStatus(
            ATSMiniDBContext db,
            Application application,
            ApplicationStatus newStatus,
            int changedByUserId,
            string note,
            DateTime changedAt)
        {
            var oldStatusId = application.StatusID;
            application.StatusID = newStatus.StatusID;
            db.ApplicationStatusHistories.Add(new ApplicationStatusHistory
            {
                ApplicationID = application.ApplicationID,
                OldStatusID = oldStatusId,
                NewStatusID = newStatus.StatusID,
                ChangedByUserID = changedByUserId,
                ChangedAt = changedAt,
                Note = note
            });
        }

        private static void SyncApplicationStatusFromResult(
            ATSMiniDBContext db,
            Application application,
            string result,
            int changedByUserId,
            DateTime changedAt)
        {
            string targetStatusName = null;
            if (string.Equals(result, "Đạt", StringComparison.Ordinal))
            {
                targetStatusName = "Đạt";
            }
            else if (string.Equals(result, "Không đạt", StringComparison.Ordinal))
            {
                targetStatusName = "Không đạt";
            }

            if (targetStatusName == null)
            {
                return;
            }

            var status = db.ApplicationStatuses
                .SingleOrDefault(s => s.StatusName == targetStatusName);
            if (status == null || application.StatusID == status.StatusID)
            {
                return;
            }

            ChangeApplicationStatus(
                db,
                application,
                status,
                changedByUserId,
                "Đồng bộ trạng thái từ kết quả phỏng vấn.",
                changedAt);
        }

        private static void ReconcileApplicationStatus(
            ATSMiniDBContext db,
            Application application,
            int excludedInterviewId,
            bool currentInterviewRemainsActive,
            int changedByUserId,
            DateTime changedAt,
            string note)
        {
            var remainingInterviews = db.Interviews
                .AsNoTracking()
                .Where(i => i.ApplicationID == application.ApplicationID &&
                            i.InterviewID != excludedInterviewId &&
                            !i.IsDeleted)
                .OrderByDescending(i => i.InterviewDate)
                .Select(i => i.Result)
                .ToList();

            var latestFinalResult = remainingInterviews.FirstOrDefault(IsFinalResult);
            var targetStatusName = latestFinalResult ??
                                   (currentInterviewRemainsActive || remainingInterviews.Any()
                                       ? "Mời phỏng vấn"
                                       : "Đang xem xét");
            var targetStatus = db.ApplicationStatuses
                .SingleOrDefault(s => s.StatusName == targetStatusName);

            if (targetStatus == null || application.StatusID == targetStatus.StatusID)
            {
                return;
            }

            ChangeApplicationStatus(
                db,
                application,
                targetStatus,
                changedByUserId,
                note,
                changedAt);
        }

        private static bool IsFinalResult(string result)
        {
            return string.Equals(result, "Đạt", StringComparison.Ordinal) ||
                   string.Equals(result, "Không đạt", StringComparison.Ordinal);
        }

        private static void PopulateEditorOptions(
            ATSMiniDBContext db,
            InterviewEditViewModel model)
        {
            var applicationQuery = db.Applications
                .AsNoTracking()
                .Where(a => !a.IsDeleted);
            if (!model.IsEdit)
            {
                applicationQuery = applicationQuery
                    .Where(a => !a.ApplicationStatus.IsFinal);
            }

            var applications = applicationQuery
                .OrderByDescending(a => a.AppliedDate)
                .Select(a => new
                {
                    a.ApplicationID,
                    a.CandidateName,
                    JobTitle = a.Job.Title
                })
                .ToList();
            model.ApplicationOptions = applications
                .Select(a => new SelectListItem
                {
                    Value = a.ApplicationID.ToString(),
                    Text = "#" + a.ApplicationID.ToString("D4") + " · " +
                           a.CandidateName + " · " + a.JobTitle,
                    Selected = a.ApplicationID == model.ApplicationId
                })
                .ToList();

            var interviewers = db.Users
                .AsNoTracking()
                .Where(u => u.IsActive &&
                            u.Role.IsActive &&
                            (u.Role.RoleName == "Admin" || u.Role.RoleName == "HR"))
                .OrderBy(u => u.FullName)
                .Select(u => new { u.UserID, u.FullName, u.Role.RoleName })
                .ToList();
            model.InterviewerOptions = interviewers
                .Select(u => new SelectListItem
                {
                    Value = u.UserID.ToString(),
                    Text = u.FullName + " · " +
                           (u.RoleName == "HR" ? "Nhân sự" : "Quản trị viên"),
                    Selected = model.InterviewerUserId.HasValue &&
                               u.UserID == model.InterviewerUserId.Value
                })
                .ToList();

            model.ResultOptions = BuildResultOptions(model.Result);

            var selectedApplication = applications
                .SingleOrDefault(a => a.ApplicationID == model.ApplicationId);
            if (selectedApplication != null)
            {
                model.CandidateName = selectedApplication.CandidateName;
                model.JobTitle = selectedApplication.JobTitle;
            }
        }

        private static System.Collections.Generic.IList<SelectListItem> BuildResultOptions(string selected)
        {
            return InterviewResults
                .Select(value => new SelectListItem
                {
                    Value = value,
                    Text = value,
                    Selected = string.Equals(value, selected, StringComparison.Ordinal)
                })
                .ToList();
        }

        private static string Normalize(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private static string NormalizeResult(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? InterviewResults[0] : value.Trim();
        }

        private int GetCurrentUserId()
        {
            return Convert.ToInt32(Session[AuthSessionKeys.UserID]);
        }
    }
}
