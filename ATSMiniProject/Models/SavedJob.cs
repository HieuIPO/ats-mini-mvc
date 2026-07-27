namespace ATSMiniProject.Models
{
    using System;

    public partial class SavedJob
    {
        public int SavedJobID { get; set; }
        public int CandidateUserID { get; set; }
        public int JobID { get; set; }
        public DateTime SavedAt { get; set; }

        public virtual User CandidateUser { get; set; }
        public virtual Job Job { get; set; }
    }
}
