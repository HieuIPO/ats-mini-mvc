using System;
using System.Collections.Generic;

namespace ATSMiniProject.ViewModels.Notifications
{
    public class NotificationItemViewModel
    {
        public int NotificationId { get; set; }
        public int? ApplicationId { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsRead { get; set; }
    }

    public class NotificationTopbarViewModel
    {
        public int UnreadCount { get; set; }
        public IReadOnlyList<NotificationItemViewModel> RecentItems { get; set; }
    }

    public class NotificationIndexViewModel
    {
        public int UnreadCount { get; set; }
        public int Page { get; set; }
        public int TotalPages { get; set; }
        public int TotalItems { get; set; }
        public int FirstItem { get; set; }
        public int LastItem { get; set; }
        public IReadOnlyList<NotificationItemViewModel> Items { get; set; }
    }
}
