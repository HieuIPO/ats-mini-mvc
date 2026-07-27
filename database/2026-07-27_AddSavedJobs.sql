/* Adds candidate saved jobs to an existing ATSMiniDB_StudentPlus database. */
USE [ATSMiniDB_StudentPlus];
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

IF OBJECT_ID(N'dbo.SavedJobs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SavedJobs (
        SavedJobID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        CandidateUserID INT NOT NULL,
        JobID INT NOT NULL,
        SavedAt DATETIME NOT NULL CONSTRAINT DF_SavedJobs_SavedAt DEFAULT GETDATE(),
        CONSTRAINT FK_SavedJobs_Candidate FOREIGN KEY (CandidateUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_SavedJobs_Job FOREIGN KEY (JobID) REFERENCES dbo.Jobs(JobID) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_SavedJobs_Candidate_Job'
      AND object_id = OBJECT_ID(N'dbo.SavedJobs')
)
BEGIN
    CREATE UNIQUE INDEX UX_SavedJobs_Candidate_Job
        ON dbo.SavedJobs(CandidateUserID, JobID);
END;

COMMIT TRANSACTION;
GO

/* Rollback, if required:
USE [ATSMiniDB_StudentPlus];
GO
IF OBJECT_ID(N'dbo.SavedJobs', N'U') IS NOT NULL
    DROP TABLE dbo.SavedJobs;
GO
*/
