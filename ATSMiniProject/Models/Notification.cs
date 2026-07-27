using System;

namespace ATSMiniProject.Models
{
    public partial class Notification
    {
        public int NotificationID { get; set; }
        public int RecipientUserID { get; set; }
        public int? ApplicationID { get; set; }
        public string NotificationType { get; set; }
        public string Title { get; set; }
        public string Message { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ReadAt { get; set; }

        public virtual User RecipientUser { get; set; }
        public virtual Application Application { get; set; }
    }
}
