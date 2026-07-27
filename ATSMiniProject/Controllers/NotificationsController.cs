using System;
using System.Data.Entity;
using System.Linq;
using System.Web.Mvc;
using ATSMiniProject.Filters;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;
using ATSMiniProject.ViewModels.Notifications;

namespace ATSMiniProject.Controllers
{
    [AuthorizeRole("Admin", "HR")]
    public class NotificationsController : Controller
    {
        private const int PageSize = 12;

        [ChildActionOnly]
        public ActionResult TopbarBell()
        {
            var currentUserId = CurrentUserId();
            using (var db = new ATSMiniDBContext())
            {
                var query = db.Notifications
                    .AsNoTracking()
                    .Where(n => n.RecipientUserID == currentUserId);

                return PartialView("_TopbarBell", new NotificationTopbarViewModel
                {
                    UnreadCount = query.Count(n => n.ReadAt == null),
                    RecentItems = query
                        .OrderByDescending(n => n.CreatedAt)
                        .Take(5)
                        .Select(n => new NotificationItemViewModel
                        {
                            NotificationId = n.NotificationID,
                            ApplicationId = n.ApplicationID,
                            Title = n.Title,
                            Message = n.Message,
                            CreatedAt = n.CreatedAt,
                            IsRead = n.ReadAt != null
                        })
                        .ToList()
                });
            }
        }

        [HttpGet]
        public ActionResult Index(int page = 1)
        {
            var currentUserId = CurrentUserId();
            using (var db = new ATSMiniDBContext())
            {
                var query = db.Notifications
                    .AsNoTracking()
                    .Where(n => n.RecipientUserID == currentUserId);
                var totalItems = query.Count();
                var pagination = Pagination.Calculate(page, totalItems, PageSize);

                return View(new NotificationIndexViewModel
                {
                    UnreadCount = query.Count(n => n.ReadAt == null),
                    Page = pagination.Page,
                    TotalPages = pagination.TotalPages,
                    TotalItems = pagination.TotalItems,
                    FirstItem = pagination.FirstItem,
                    LastItem = pagination.LastItem,
                    Items = query
                        .OrderByDescending(n => n.CreatedAt)
                        .ThenByDescending(n => n.NotificationID)
                        .Skip(pagination.Offset)
                        .Take(pagination.PageSize)
                        .Select(n => new NotificationItemViewModel
                        {
                            NotificationId = n.NotificationID,
                            ApplicationId = n.ApplicationID,
                            Title = n.Title,
                            Message = n.Message,
                            CreatedAt = n.CreatedAt,
                            IsRead = n.ReadAt != null
                        })
                        .ToList()
                });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Open(int id)
        {
            var currentUserId = CurrentUserId();
            using (var db = new ATSMiniDBContext())
            {
                var notification = db.Notifications.SingleOrDefault(n =>
                    n.NotificationID == id &&
                    n.RecipientUserID == currentUserId);
                if (notification == null)
                {
                    return HttpNotFound();
                }

                if (notification.ReadAt == null)
                {
                    notification.ReadAt = DateTime.Now;
                    db.SaveChanges();
                }

                if (!notification.ApplicationID.HasValue ||
                    !db.Applications.Any(a =>
                        a.ApplicationID == notification.ApplicationID.Value &&
                        !a.IsDeleted))
                {
                    TempData["Error"] = "Hồ sơ liên quan không còn khả dụng.";
                    return RedirectToAction("Index");
                }

                return RedirectToAction(
                    "Review",
                    "Applications",
                    new { id = notification.ApplicationID.Value });
            }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult MarkAllRead()
        {
            var currentUserId = CurrentUserId();
            using (var db = new ATSMiniDBContext())
            {
                var now = DateTime.Now;
                var unread = db.Notifications
                    .Where(n => n.RecipientUserID == currentUserId && n.ReadAt == null)
                    .ToList();

                foreach (var notification in unread)
                {
                    notification.ReadAt = now;
                }

                db.SaveChanges();
            }

            return RedirectToAction("Index");
        }

        private int CurrentUserId()
        {
            return Convert.ToInt32(Session[AuthSessionKeys.UserID]);
        }
    }
}
