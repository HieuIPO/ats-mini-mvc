using System;
using System.Data.Entity;
using System.Diagnostics;
using System.Linq;
using ATSMiniProject.Helpers;
using ATSMiniProject.Models;

namespace ATSMiniProject.Services
{
    public class NotificationService
    {
        private const string NewApplicationType = "NEW_APPLICATION";

        public void CreateNewApplicationNotification(int applicationId)
        {
            using (var db = new ATSMiniDBContext())
            {
                var application = db.Applications
                    .Include(a => a.Job.User.Role)
                    .SingleOrDefault(a => a.ApplicationID == applicationId && !a.IsDeleted);
                if (application == null)
                {
                    return;
                }

                var creator = application.Job == null ? null : application.Job.User;
                var creatorIsEligible = creator != null &&
                    creator.IsActive &&
                    creator.Role != null &&
                    InternalAccountRolePolicy.IsAllowedRoleName(creator.Role.RoleName);

                var adminIds = creatorIsEligible
                    ? Enumerable.Empty<int>()
                    : db.Users
                        .Where(u => u.IsActive && u.Role.RoleName == InternalAccountRolePolicy.AdminRoleName)
                        .Select(u => u.UserID)
                        .ToList();

                var recipientIds = NotificationRecipientPolicy.Resolve(
                    application.Job == null ? null : application.Job.CreatedByUserID,
                    creatorIsEligible,
                    adminIds);

                if (recipientIds.Count == 0)
                {
                    Trace.TraceWarning(
                        "No eligible notification recipient for application {0}.",
                        application.ApplicationID);
                    return;
                }

                foreach (var recipientId in recipientIds)
                {
                    var exists = db.Notifications.Any(n =>
                        n.ApplicationID == application.ApplicationID &&
                        n.RecipientUserID == recipientId &&
                        n.NotificationType == NewApplicationType);
                    if (exists)
                    {
                        continue;
                    }

                    db.Notifications.Add(new Notification
                    {
                        RecipientUserID = recipientId,
                        ApplicationID = application.ApplicationID,
                        NotificationType = NewApplicationType,
                        Title = "Hồ sơ ứng tuyển mới",
                        Message = application.CandidateName + " vừa ứng tuyển " + application.Job.Title + ".",
                        CreatedAt = DateTime.Now
                    });
                }

                db.SaveChanges();
            }
        }
    }
}
