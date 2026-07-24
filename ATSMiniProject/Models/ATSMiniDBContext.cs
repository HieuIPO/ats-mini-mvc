using System.Data.Entity;

namespace ATSMiniProject.Models
{
    public partial class ATSMiniDBContext : DbContext
    {
        public ATSMiniDBContext()
            : base("name=ModelDB")
        {
        }

        public virtual DbSet<Application> Applications { get; set; }
        public virtual DbSet<ApplicationStatus> ApplicationStatuses { get; set; }
        public virtual DbSet<ApplicationStatusHistory> ApplicationStatusHistories { get; set; }
        public virtual DbSet<AuditLog> AuditLogs { get; set; }
        public virtual DbSet<CandidateFile> CandidateFiles { get; set; }
        public virtual DbSet<Department> Departments { get; set; }
        public virtual DbSet<Interview> Interviews { get; set; }
        public virtual DbSet<Job> Jobs { get; set; }
        public virtual DbSet<JobPosition> JobPositions { get; set; }
        public virtual DbSet<Role> Roles { get; set; }
        public virtual DbSet<User> Users { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Application>()
                .ToTable("Applications")
                .HasKey(e => e.ApplicationID);
            modelBuilder.Entity<Application>().Property(e => e.CandidateName).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<Application>().Property(e => e.CandidatePhone).IsRequired().HasMaxLength(20);
            modelBuilder.Entity<Application>().Property(e => e.CandidateEmail).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<Application>().Property(e => e.CVFilePath).HasMaxLength(255);

            modelBuilder.Entity<ApplicationStatus>()
                .ToTable("ApplicationStatuses")
                .HasKey(e => e.StatusID);
            modelBuilder.Entity<ApplicationStatus>().Property(e => e.StatusName).IsRequired().HasMaxLength(50);
            modelBuilder.Entity<ApplicationStatus>().Property(e => e.Description).HasMaxLength(255);

            modelBuilder.Entity<ApplicationStatusHistory>()
                .ToTable("ApplicationStatusHistories")
                .HasKey(e => e.HistoryID);
            modelBuilder.Entity<ApplicationStatusHistory>().Property(e => e.Note).HasMaxLength(500);

            modelBuilder.Entity<AuditLog>()
                .ToTable("AuditLogs")
                .HasKey(e => e.AuditLogID);
            modelBuilder.Entity<AuditLog>().Property(e => e.ActionName).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<AuditLog>().Property(e => e.TableName).HasMaxLength(100);
            modelBuilder.Entity<AuditLog>().Property(e => e.Description).HasMaxLength(500);
            modelBuilder.Entity<AuditLog>().Property(e => e.IpAddress).HasMaxLength(50);

            modelBuilder.Entity<CandidateFile>()
                .ToTable("CandidateFiles")
                .HasKey(e => e.CandidateFileID);
            modelBuilder.Entity<CandidateFile>().Property(e => e.OriginalFileName).IsRequired().HasMaxLength(255);
            modelBuilder.Entity<CandidateFile>().Property(e => e.StoredFileName).IsRequired().HasMaxLength(255);
            modelBuilder.Entity<CandidateFile>().Property(e => e.FilePath).IsRequired().HasMaxLength(255);
            modelBuilder.Entity<CandidateFile>().Property(e => e.FileExtension).IsRequired().HasMaxLength(10);

            modelBuilder.Entity<Department>()
                .ToTable("Departments")
                .HasKey(e => e.DepartmentID);
            modelBuilder.Entity<Department>().Property(e => e.DepartmentName).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<Department>().Property(e => e.Description).HasMaxLength(255);

            modelBuilder.Entity<Interview>()
                .ToTable("Interviews")
                .HasKey(e => e.InterviewID);
            modelBuilder.Entity<Interview>().Property(e => e.InterviewLocation).HasMaxLength(150);
            modelBuilder.Entity<Interview>().Property(e => e.Result).HasMaxLength(100);

            modelBuilder.Entity<Job>()
                .ToTable("Jobs")
                .HasKey(e => e.JobID);
            modelBuilder.Entity<Job>().Property(e => e.Title).IsRequired().HasMaxLength(150);
            modelBuilder.Entity<Job>().Property(e => e.Industry).HasMaxLength(100);
            modelBuilder.Entity<Job>().Property(e => e.SalaryRange).HasMaxLength(100);
            modelBuilder.Entity<Job>().Property(e => e.Location).HasMaxLength(150);
            modelBuilder.Entity<Job>().Property(e => e.JobType).HasMaxLength(50);
            modelBuilder.Entity<Job>().Property(e => e.Deadline).HasColumnType("date");

            modelBuilder.Entity<JobPosition>()
                .ToTable("JobPositions")
                .HasKey(e => e.JobPositionID);
            modelBuilder.Entity<JobPosition>().Property(e => e.PositionName).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<JobPosition>().Property(e => e.Description).HasMaxLength(255);

            modelBuilder.Entity<Role>()
                .ToTable("Roles")
                .HasKey(e => e.RoleID);
            modelBuilder.Entity<Role>().Property(e => e.RoleName).IsRequired().HasMaxLength(50);
            modelBuilder.Entity<Role>().Property(e => e.Description).HasMaxLength(255);

            modelBuilder.Entity<User>()
                .ToTable("Users")
                .HasKey(e => e.UserID);
            modelBuilder.Entity<User>().Property(e => e.Username).IsRequired().HasMaxLength(50);
            modelBuilder.Entity<User>().Property(e => e.PasswordHash).IsRequired().HasMaxLength(128);
            modelBuilder.Entity<User>().Property(e => e.PasswordSalt).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<User>().Property(e => e.FullName).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<User>().Property(e => e.Email).IsRequired().HasMaxLength(100);
            modelBuilder.Entity<User>().Property(e => e.Phone).HasMaxLength(20);

            modelBuilder.Entity<Role>()
                .HasMany(e => e.Users)
                .WithRequired(e => e.Role)
                .HasForeignKey(e => e.RoleID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<Job>()
                .HasMany(e => e.Applications)
                .WithRequired(e => e.Job)
                .HasForeignKey(e => e.JobID)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<Application>()
                .HasMany(e => e.CandidateFiles)
                .WithRequired(e => e.Application)
                .HasForeignKey(e => e.ApplicationID)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<Application>()
                .HasMany(e => e.Interviews)
                .WithRequired(e => e.Application)
                .HasForeignKey(e => e.ApplicationID)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<Application>()
                .HasMany(e => e.ApplicationStatusHistories)
                .WithRequired(e => e.Application)
                .HasForeignKey(e => e.ApplicationID)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<ApplicationStatus>()
                .HasMany(e => e.Applications)
                .WithRequired(e => e.ApplicationStatus)
                .HasForeignKey(e => e.StatusID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<ApplicationStatus>()
                .HasMany(e => e.ApplicationStatusHistories)
                .WithOptional(e => e.ApplicationStatus)
                .HasForeignKey(e => e.OldStatusID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<ApplicationStatus>()
                .HasMany(e => e.ApplicationStatusHistories1)
                .WithRequired(e => e.ApplicationStatus1)
                .HasForeignKey(e => e.NewStatusID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<Department>()
                .HasMany(e => e.Jobs)
                .WithRequired(e => e.Department)
                .HasForeignKey(e => e.DepartmentID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<JobPosition>()
                .HasMany(e => e.Jobs)
                .WithRequired(e => e.JobPosition)
                .HasForeignKey(e => e.JobPositionID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Applications)
                .WithOptional(e => e.User)
                .HasForeignKey(e => e.CandidateUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Applications1)
                .WithOptional(e => e.User1)
                .HasForeignKey(e => e.UpdatedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.ApplicationStatusHistories)
                .WithOptional(e => e.User)
                .HasForeignKey(e => e.ChangedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.AuditLogs)
                .WithOptional(e => e.User)
                .HasForeignKey(e => e.UserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.CandidateFiles)
                .WithOptional(e => e.User)
                .HasForeignKey(e => e.UploadedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Departments)
                .WithOptional(e => e.User)
                .HasForeignKey(e => e.CreatedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Departments1)
                .WithOptional(e => e.User1)
                .HasForeignKey(e => e.UpdatedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Interviews)
                .WithOptional(e => e.User)
                .HasForeignKey(e => e.InterviewerUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Interviews1)
                .WithOptional(e => e.User1)
                .HasForeignKey(e => e.CreatedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Interviews2)
                .WithOptional(e => e.User2)
                .HasForeignKey(e => e.UpdatedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.JobPositions)
                .WithOptional(e => e.User)
                .HasForeignKey(e => e.CreatedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.JobPositions1)
                .WithOptional(e => e.User1)
                .HasForeignKey(e => e.UpdatedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Jobs)
                .WithOptional(e => e.User)
                .HasForeignKey(e => e.CreatedByUserID)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<User>()
                .HasMany(e => e.Jobs1)
                .WithOptional(e => e.User1)
                .HasForeignKey(e => e.UpdatedByUserID)
                .WillCascadeOnDelete(false);
        }
    }
}
