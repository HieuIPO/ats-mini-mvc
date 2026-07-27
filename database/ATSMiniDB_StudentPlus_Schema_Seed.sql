/*
  ATSMiniDB_StudentPlus - SQL Server schema + sample data
  Muc tieu: Du tot cho do an sinh vien, khong so sai, nhung khong qua nang nhu he thong doanh nghiep that.

  Cong nghe du kien:
  - ASP.NET MVC 5 / .NET Framework
  - Entity Framework 6 Code First from database
  - SQL Server

  Cach dung:
  1. Mo SQL Server Management Studio.
  2. Chay toan bo script nay.
  3. Ung dung ket noi database ATSMiniDB_StudentPlus qua connection string ATSMiniDBContext.

  Luu y quan trong ve mat khau:
  - Script nay khong luu mat khau ro.
  - Mat khau demo van la: 123456
  - PasswordHash trong seed data duoc tao bang SHA2_256(Salt + Password) trong SQL Server.
  - Day la muc demo tot hon plain text cho mon hoc, chua phai chuan production nhu ASP.NET Identity/PBKDF2/bcrypt/Argon2.
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF DB_ID(N'ATSMiniDB_StudentPlus') IS NULL
BEGIN
    CREATE DATABASE ATSMiniDB_StudentPlus;
END
GO

USE ATSMiniDB_StudentPlus;
GO

/* =====================================================
   1. MASTER / SECURITY TABLES
   ===================================================== */

IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Roles (
        RoleID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        RoleName NVARCHAR(50) NOT NULL UNIQUE,
        Description NVARCHAR(255) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Roles_IsActive DEFAULT 1
    );
END
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        UserID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Username NVARCHAR(50) NOT NULL UNIQUE,
        PasswordHash NVARCHAR(128) NOT NULL,
        PasswordSalt NVARCHAR(100) NOT NULL,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) NOT NULL UNIQUE,
        Phone NVARCHAR(20) NULL,
        RoleID INT NOT NULL,
        FailedLoginCount INT NOT NULL CONSTRAINT DF_Users_FailedLoginCount DEFAULT 0,
        LockedUntil DATETIME NULL,
        LastLoginAt DATETIME NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Users_IsActive DEFAULT 1,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT GETDATE(),
        UpdatedAt DATETIME NULL,
        CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES dbo.Roles(RoleID)
    );
END
GO

/* =====================================================
   2. RECRUITMENT MASTER DATA
   ===================================================== */

IF OBJECT_ID(N'dbo.Departments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Departments (
        DepartmentID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        DepartmentName NVARCHAR(100) NOT NULL UNIQUE,
        Description NVARCHAR(255) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Departments_IsActive DEFAULT 1,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Departments_IsDeleted DEFAULT 0,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_Departments_CreatedAt DEFAULT GETDATE(),
        CreatedByUserID INT NULL,
        UpdatedAt DATETIME NULL,
        UpdatedByUserID INT NULL,
        CONSTRAINT FK_Departments_CreatedBy FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Departments_UpdatedBy FOREIGN KEY (UpdatedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID(N'dbo.JobPositions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.JobPositions (
        JobPositionID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        PositionName NVARCHAR(100) NOT NULL UNIQUE,
        Description NVARCHAR(255) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_JobPositions_IsActive DEFAULT 1,
        IsDeleted BIT NOT NULL CONSTRAINT DF_JobPositions_IsDeleted DEFAULT 0,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_JobPositions_CreatedAt DEFAULT GETDATE(),
        CreatedByUserID INT NULL,
        UpdatedAt DATETIME NULL,
        UpdatedByUserID INT NULL,
        CONSTRAINT FK_JobPositions_CreatedBy FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_JobPositions_UpdatedBy FOREIGN KEY (UpdatedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID(N'dbo.Jobs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Jobs (
        JobID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        Title NVARCHAR(150) NOT NULL,
        Description NVARCHAR(MAX) NOT NULL,
        Requirements NVARCHAR(MAX) NULL,
        DepartmentID INT NOT NULL,
        JobPositionID INT NOT NULL,
        Industry NVARCHAR(100) NULL,
        SalaryRange NVARCHAR(100) NULL,
        Location NVARCHAR(150) NULL,
        JobType NVARCHAR(50) NULL,
        Deadline DATE NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_Jobs_IsActive DEFAULT 1,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Jobs_IsDeleted DEFAULT 0,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_Jobs_CreatedAt DEFAULT GETDATE(),
        CreatedByUserID INT NULL,
        UpdatedAt DATETIME NULL,
        UpdatedByUserID INT NULL,
        CONSTRAINT FK_Jobs_Departments FOREIGN KEY (DepartmentID) REFERENCES dbo.Departments(DepartmentID),
        CONSTRAINT FK_Jobs_JobPositions FOREIGN KEY (JobPositionID) REFERENCES dbo.JobPositions(JobPositionID),
        CONSTRAINT FK_Jobs_CreatedBy FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Jobs_UpdatedBy FOREIGN KEY (UpdatedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

/* =====================================================
   3. APPLICATION TRACKING
   ===================================================== */

IF OBJECT_ID(N'dbo.ApplicationStatuses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ApplicationStatuses (
        StatusID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        StatusName NVARCHAR(50) NOT NULL UNIQUE,
        Description NVARCHAR(255) NULL,
        DisplayOrder INT NOT NULL CONSTRAINT DF_ApplicationStatuses_DisplayOrder DEFAULT 0,
        IsFinal BIT NOT NULL CONSTRAINT DF_ApplicationStatuses_IsFinal DEFAULT 0
    );
END
GO

IF OBJECT_ID(N'dbo.Applications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Applications (
        ApplicationID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        JobID INT NOT NULL,
        CandidateUserID INT NULL,
        CandidateName NVARCHAR(100) NOT NULL,
        CandidatePhone NVARCHAR(20) NOT NULL,
        CandidateEmail NVARCHAR(100) NOT NULL,
        CVFilePath NVARCHAR(255) NULL,
        StatusID INT NOT NULL,
        HRNote NVARCHAR(MAX) NULL,
        AppliedDate DATETIME NOT NULL CONSTRAINT DF_Applications_AppliedDate DEFAULT GETDATE(),
        UpdatedAt DATETIME NULL,
        UpdatedByUserID INT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Applications_IsDeleted DEFAULT 0,
        CONSTRAINT FK_Applications_Jobs FOREIGN KEY (JobID) REFERENCES dbo.Jobs(JobID) ON DELETE CASCADE,
        CONSTRAINT FK_Applications_CandidateUser FOREIGN KEY (CandidateUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Applications_Statuses FOREIGN KEY (StatusID) REFERENCES dbo.ApplicationStatuses(StatusID),
        CONSTRAINT FK_Applications_UpdatedBy FOREIGN KEY (UpdatedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID(N'dbo.CandidateFiles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CandidateFiles (
        CandidateFileID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplicationID INT NOT NULL,
        OriginalFileName NVARCHAR(255) NOT NULL,
        StoredFileName NVARCHAR(255) NOT NULL,
        FilePath NVARCHAR(255) NOT NULL,
        FileExtension NVARCHAR(10) NOT NULL,
        FileSizeKB INT NULL,
        UploadedAt DATETIME NOT NULL CONSTRAINT DF_CandidateFiles_UploadedAt DEFAULT GETDATE(),
        UploadedByUserID INT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_CandidateFiles_IsDeleted DEFAULT 0,
        CONSTRAINT FK_CandidateFiles_Applications FOREIGN KEY (ApplicationID) REFERENCES dbo.Applications(ApplicationID) ON DELETE CASCADE,
        CONSTRAINT FK_CandidateFiles_UploadedBy FOREIGN KEY (UploadedByUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT CK_CandidateFiles_Extension CHECK (FileExtension IN (N'.pdf', N'.doc', N'.docx')),
        CONSTRAINT CK_CandidateFiles_Size CHECK (FileSizeKB IS NULL OR (FileSizeKB > 0 AND FileSizeKB <= 5120))
    );
END
GO

IF OBJECT_ID(N'dbo.CandidateFiles', N'U') IS NOT NULL
   AND NOT EXISTS (
       SELECT 1
       FROM sys.check_constraints
       WHERE name = N'CK_CandidateFiles_Size'
         AND parent_object_id = OBJECT_ID(N'dbo.CandidateFiles')
   )
BEGIN
    ALTER TABLE dbo.CandidateFiles
    ADD CONSTRAINT CK_CandidateFiles_Size
        CHECK (FileSizeKB IS NULL OR (FileSizeKB > 0 AND FileSizeKB <= 5120));
END
GO

IF OBJECT_ID(N'dbo.ApplicationStatusHistories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ApplicationStatusHistories (
        HistoryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplicationID INT NOT NULL,
        OldStatusID INT NULL,
        NewStatusID INT NOT NULL,
        ChangedByUserID INT NULL,
        ChangedAt DATETIME NOT NULL CONSTRAINT DF_ApplicationStatusHistories_ChangedAt DEFAULT GETDATE(),
        Note NVARCHAR(500) NULL,
        CONSTRAINT FK_StatusHistories_Applications FOREIGN KEY (ApplicationID) REFERENCES dbo.Applications(ApplicationID) ON DELETE CASCADE,
        CONSTRAINT FK_StatusHistories_OldStatus FOREIGN KEY (OldStatusID) REFERENCES dbo.ApplicationStatuses(StatusID),
        CONSTRAINT FK_StatusHistories_NewStatus FOREIGN KEY (NewStatusID) REFERENCES dbo.ApplicationStatuses(StatusID),
        CONSTRAINT FK_StatusHistories_ChangedBy FOREIGN KEY (ChangedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID(N'dbo.Interviews', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Interviews (
        InterviewID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ApplicationID INT NOT NULL,
        InterviewDate DATETIME NOT NULL,
        InterviewLocation NVARCHAR(150) NULL,
        InterviewerUserID INT NULL,
        Note NVARCHAR(MAX) NULL,
        Result NVARCHAR(100) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_Interviews_CreatedAt DEFAULT GETDATE(),
        CreatedByUserID INT NULL,
        UpdatedAt DATETIME NULL,
        UpdatedByUserID INT NULL,
        IsDeleted BIT NOT NULL CONSTRAINT DF_Interviews_IsDeleted DEFAULT 0,
        CONSTRAINT FK_Interviews_Applications FOREIGN KEY (ApplicationID) REFERENCES dbo.Applications(ApplicationID) ON DELETE CASCADE,
        CONSTRAINT FK_Interviews_Interviewer FOREIGN KEY (InterviewerUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Interviews_CreatedBy FOREIGN KEY (CreatedByUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Interviews_UpdatedBy FOREIGN KEY (UpdatedByUserID) REFERENCES dbo.Users(UserID)
    );
END
GO

/* =====================================================
   4. AUDIT LOG
   ===================================================== */

IF OBJECT_ID(N'dbo.AuditLogs', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AuditLogs (
        AuditLogID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserID INT NULL,
        ActionName NVARCHAR(100) NOT NULL,
        TableName NVARCHAR(100) NULL,
        RecordID INT NULL,
        Description NVARCHAR(500) NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_AuditLogs_CreatedAt DEFAULT GETDATE(),
        IpAddress NVARCHAR(50) NULL,
        CONSTRAINT FK_AuditLogs_Users FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
    );
END
GO

IF OBJECT_ID(N'dbo.Notifications', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Notifications (
        NotificationID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        RecipientUserID INT NOT NULL,
        ApplicationID INT NULL,
        NotificationType NVARCHAR(50) NOT NULL,
        Title NVARCHAR(150) NOT NULL,
        Message NVARCHAR(500) NOT NULL,
        CreatedAt DATETIME NOT NULL CONSTRAINT DF_Notifications_CreatedAt DEFAULT GETDATE(),
        ReadAt DATETIME NULL,
        CONSTRAINT FK_Notifications_Recipient FOREIGN KEY (RecipientUserID) REFERENCES dbo.Users(UserID),
        CONSTRAINT FK_Notifications_Application FOREIGN KEY (ApplicationID) REFERENCES dbo.Applications(ApplicationID)
    );
END
GO

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
END
GO

/* =====================================================
   5. INDEXES
   ===================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Jobs_Active_Deadline' AND object_id = OBJECT_ID(N'dbo.Jobs'))
    CREATE INDEX IX_Jobs_Active_Deadline ON dbo.Jobs(IsActive, IsDeleted, Deadline);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Applications_Job_Status' AND object_id = OBJECT_ID(N'dbo.Applications'))
    CREATE INDEX IX_Applications_Job_Status ON dbo.Applications(JobID, StatusID, IsDeleted);
GO

IF EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE name = N'UQ_Applications_Job_Email'
      AND parent_object_id = OBJECT_ID(N'dbo.Applications')
)
    ALTER TABLE dbo.Applications DROP CONSTRAINT UQ_Applications_Job_Email;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Applications_Job_Email' AND object_id = OBJECT_ID(N'dbo.Applications'))
    CREATE UNIQUE INDEX UX_Applications_Job_Email
        ON dbo.Applications(JobID, CandidateEmail)
        WHERE IsDeleted = 0;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Applications_Job_Candidate' AND object_id = OBJECT_ID(N'dbo.Applications'))
    CREATE UNIQUE INDEX UX_Applications_Job_Candidate
        ON dbo.Applications(JobID, CandidateUserID)
        WHERE CandidateUserID IS NOT NULL AND IsDeleted = 0;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Interviews_Date' AND object_id = OBJECT_ID(N'dbo.Interviews'))
    CREATE INDEX IX_Interviews_Date ON dbo.Interviews(InterviewDate, IsDeleted);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Notifications_Application_Recipient_Type' AND object_id = OBJECT_ID(N'dbo.Notifications'))
    CREATE UNIQUE INDEX UX_Notifications_Application_Recipient_Type
        ON dbo.Notifications(ApplicationID, RecipientUserID, NotificationType)
        WHERE ApplicationID IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Notifications_Recipient_Read_Created' AND object_id = OBJECT_ID(N'dbo.Notifications'))
    CREATE INDEX IX_Notifications_Recipient_Read_Created
        ON dbo.Notifications(RecipientUserID, ReadAt, CreatedAt DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_SavedJobs_Candidate_Job' AND object_id = OBJECT_ID(N'dbo.SavedJobs'))
    CREATE UNIQUE INDEX UX_SavedJobs_Candidate_Job
        ON dbo.SavedJobs(CandidateUserID, JobID);
GO

/* =====================================================
   6. SEED DATA
   ===================================================== */

INSERT INTO dbo.Roles (RoleName, Description)
SELECT N'Admin', N'Quan tri he thong'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleName = N'Admin');

INSERT INTO dbo.Roles (RoleName, Description)
SELECT N'HR', N'Nhan su tuyen dung'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleName = N'HR');

INSERT INTO dbo.Roles (RoleName, Description)
SELECT N'Candidate', N'Ung vien'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleName = N'Candidate');
GO

DECLARE @DefaultPassword NVARCHAR(50) = N'123456';

INSERT INTO dbo.Users (Username, PasswordHash, PasswordSalt, FullName, Email, Phone, RoleID)
SELECT N'admin',
       CONVERT(NVARCHAR(128), HASHBYTES('SHA2_256', CONVERT(NVARCHAR(4000), N'ATS_DEMO_ADMIN' + @DefaultPassword)), 2),
       N'ATS_DEMO_ADMIN',
       N'Quan tri vien',
       N'admin@ats.local',
       N'0900000001',
       r.RoleID
FROM dbo.Roles r
WHERE r.RoleName = N'Admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'admin');

INSERT INTO dbo.Users (Username, PasswordHash, PasswordSalt, FullName, Email, Phone, RoleID)
SELECT N'hr01',
       CONVERT(NVARCHAR(128), HASHBYTES('SHA2_256', CONVERT(NVARCHAR(4000), N'ATS_DEMO_HR01' + @DefaultPassword)), 2),
       N'ATS_DEMO_HR01',
       N'Nguyen Thi HR',
       N'hr01@ats.local',
       N'0900000002',
       r.RoleID
FROM dbo.Roles r
WHERE r.RoleName = N'HR'
  AND NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'hr01');

INSERT INTO dbo.Users (Username, PasswordHash, PasswordSalt, FullName, Email, Phone, RoleID)
SELECT N'ungvien01',
       CONVERT(NVARCHAR(128), HASHBYTES('SHA2_256', CONVERT(NVARCHAR(4000), N'ATS_DEMO_CANDIDATE01' + @DefaultPassword)), 2),
       N'ATS_DEMO_CANDIDATE01',
       N'Tran Van Ung Vien',
       N'ungvien01@example.com',
       N'0900000003',
       r.RoleID
FROM dbo.Roles r
WHERE r.RoleName = N'Candidate'
  AND NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'ungvien01');
GO

INSERT INTO dbo.Departments (DepartmentName, Description, CreatedByUserID)
SELECT N'Phong Cong nghe thong tin', N'Phu trach phat trien phan mem va he thong', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentName = N'Phong Cong nghe thong tin');

INSERT INTO dbo.Departments (DepartmentName, Description, CreatedByUserID)
SELECT N'Phong Kinh doanh', N'Phu trach ban hang va cham soc khach hang', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentName = N'Phong Kinh doanh');

INSERT INTO dbo.Departments (DepartmentName, Description, CreatedByUserID)
SELECT N'Phong Nhan su', N'Phu trach tuyen dung va hanh chinh', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentName = N'Phong Nhan su');
GO

INSERT INTO dbo.JobPositions (PositionName, Description, CreatedByUserID)
SELECT N'Lap trinh vien Web', N'Phat trien ung dung web bang ASP.NET/C#', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.JobPositions WHERE PositionName = N'Lap trinh vien Web');

INSERT INTO dbo.JobPositions (PositionName, Description, CreatedByUserID)
SELECT N'Chuyen vien kinh doanh', N'Tim kiem va cham soc khach hang', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.JobPositions WHERE PositionName = N'Chuyen vien kinh doanh');

INSERT INTO dbo.JobPositions (PositionName, Description, CreatedByUserID)
SELECT N'Thuc tap sinh nhan su', N'Ho tro cong tac tuyen dung va ho so nhan su', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.JobPositions WHERE PositionName = N'Thuc tap sinh nhan su');
GO

INSERT INTO dbo.ApplicationStatuses (StatusName, Description, DisplayOrder, IsFinal)
SELECT N'Mới nộp', N'Ứng viên vừa nộp hồ sơ', 1, 0
WHERE NOT EXISTS (SELECT 1 FROM dbo.ApplicationStatuses WHERE StatusName = N'Mới nộp');

INSERT INTO dbo.ApplicationStatuses (StatusName, Description, DisplayOrder, IsFinal)
SELECT N'Đang xem xét', N'HR đang xem xét hồ sơ', 2, 0
WHERE NOT EXISTS (SELECT 1 FROM dbo.ApplicationStatuses WHERE StatusName = N'Đang xem xét');

INSERT INTO dbo.ApplicationStatuses (StatusName, Description, DisplayOrder, IsFinal)
SELECT N'Mời phỏng vấn', N'Ứng viên được mời phỏng vấn', 3, 0
WHERE NOT EXISTS (SELECT 1 FROM dbo.ApplicationStatuses WHERE StatusName = N'Mời phỏng vấn');

INSERT INTO dbo.ApplicationStatuses (StatusName, Description, DisplayOrder, IsFinal)
SELECT N'Đạt', N'Ứng viên đạt yêu cầu', 4, 1
WHERE NOT EXISTS (SELECT 1 FROM dbo.ApplicationStatuses WHERE StatusName = N'Đạt');

INSERT INTO dbo.ApplicationStatuses (StatusName, Description, DisplayOrder, IsFinal)
SELECT N'Không đạt', N'Ứng viên không đạt yêu cầu', 5, 1
WHERE NOT EXISTS (SELECT 1 FROM dbo.ApplicationStatuses WHERE StatusName = N'Không đạt');
GO

/* Normalize legacy non-accented or older status names from earlier demo databases. */
DECLARE @StatusMap TABLE (
    LegacyName NVARCHAR(50) NOT NULL,
    CanonicalName NVARCHAR(50) NOT NULL
);

INSERT INTO @StatusMap (LegacyName, CanonicalName)
VALUES
    (N'Moi nop', N'Mới nộp'),
    (N'Dang xem xet', N'Đang xem xét'),
    (N'Moi phong van', N'Mời phỏng vấn'),
    (N'Dat', N'Đạt'),
    (N'Truot', N'Không đạt'),
    (N'Trượt', N'Không đạt');

UPDATE a
SET a.StatusID = canonical.StatusID
FROM dbo.Applications a
JOIN dbo.ApplicationStatuses legacy ON legacy.StatusID = a.StatusID
JOIN @StatusMap sm ON sm.LegacyName = legacy.StatusName
JOIN dbo.ApplicationStatuses canonical ON canonical.StatusName = sm.CanonicalName;

UPDATE h
SET h.OldStatusID = canonical.StatusID
FROM dbo.ApplicationStatusHistories h
JOIN dbo.ApplicationStatuses legacy ON legacy.StatusID = h.OldStatusID
JOIN @StatusMap sm ON sm.LegacyName = legacy.StatusName
JOIN dbo.ApplicationStatuses canonical ON canonical.StatusName = sm.CanonicalName;

UPDATE h
SET h.NewStatusID = canonical.StatusID
FROM dbo.ApplicationStatusHistories h
JOIN dbo.ApplicationStatuses legacy ON legacy.StatusID = h.NewStatusID
JOIN @StatusMap sm ON sm.LegacyName = legacy.StatusName
JOIN dbo.ApplicationStatuses canonical ON canonical.StatusName = sm.CanonicalName;

DELETE legacy
FROM dbo.ApplicationStatuses legacy
JOIN @StatusMap sm ON sm.LegacyName = legacy.StatusName
WHERE NOT EXISTS (SELECT 1 FROM dbo.Applications a WHERE a.StatusID = legacy.StatusID)
  AND NOT EXISTS (SELECT 1 FROM dbo.ApplicationStatusHistories h WHERE h.OldStatusID = legacy.StatusID OR h.NewStatusID = legacy.StatusID);
GO

INSERT INTO dbo.Jobs (Title, Description, Requirements, DepartmentID, JobPositionID, Industry, SalaryRange, Location, JobType, Deadline, CreatedByUserID, IsActive)
SELECT N'Tuyen lap trinh vien ASP.NET MVC',
       N'Tham gia phat trien website noi bo va cac ung dung quan ly.',
       N'Biet C#, ASP.NET MVC, SQL Server. Co kien thuc HTML, CSS, JavaScript.',
       d.DepartmentID, p.JobPositionID, N'Cong nghe thong tin', N'8 - 15 trieu', N'Cao Lanh, Dong Thap', N'Full-time', DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), u.UserID, 1
FROM dbo.Departments d
JOIN dbo.JobPositions p ON p.PositionName = N'Lap trinh vien Web'
JOIN dbo.Users u ON u.Username = N'hr01'
WHERE d.DepartmentName = N'Phong Cong nghe thong tin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Jobs WHERE Title = N'Tuyen lap trinh vien ASP.NET MVC');

INSERT INTO dbo.Jobs (Title, Description, Requirements, DepartmentID, JobPositionID, Industry, SalaryRange, Location, JobType, Deadline, CreatedByUserID, IsActive)
SELECT N'Tuyen chuyen vien kinh doanh',
       N'Tim kiem khach hang moi, cham soc khach hang hien co va bao cao doanh so.',
       N'Giao tiep tot, nang dong, co kha nang lam viec nhom.',
       d.DepartmentID, p.JobPositionID, N'Kinh doanh', N'7 - 12 trieu', N'Can Tho', N'Full-time', DATEADD(DAY, 25, CAST(GETDATE() AS DATE)), u.UserID, 1
FROM dbo.Departments d
JOIN dbo.JobPositions p ON p.PositionName = N'Chuyen vien kinh doanh'
JOIN dbo.Users u ON u.Username = N'hr01'
WHERE d.DepartmentName = N'Phong Kinh doanh'
  AND NOT EXISTS (SELECT 1 FROM dbo.Jobs WHERE Title = N'Tuyen chuyen vien kinh doanh');

INSERT INTO dbo.Jobs (Title, Description, Requirements, DepartmentID, JobPositionID, Industry, SalaryRange, Location, JobType, Deadline, CreatedByUserID, IsActive)
SELECT N'Tuyen thuc tap sinh nhan su',
       N'Ho tro dang tin, loc CV, sap xep lich phong van va luu tru ho so.',
       N'Sinh vien nam 3 hoac nam 4, can than, biet dung Word/Excel co ban.',
       d.DepartmentID, p.JobPositionID, N'Nhan su', N'Ho tro 2 - 4 trieu', N'Cao Lanh, Dong Thap', N'Internship', DATEADD(DAY, 20, CAST(GETDATE() AS DATE)), u.UserID, 1
FROM dbo.Departments d
JOIN dbo.JobPositions p ON p.PositionName = N'Thuc tap sinh nhan su'
JOIN dbo.Users u ON u.Username = N'hr01'
WHERE d.DepartmentName = N'Phong Nhan su'
  AND NOT EXISTS (SELECT 1 FROM dbo.Jobs WHERE Title = N'Tuyen thuc tap sinh nhan su');
GO

INSERT INTO dbo.Applications (JobID, CandidateUserID, CandidateName, CandidatePhone, CandidateEmail, CVFilePath, StatusID, HRNote, AppliedDate)
SELECT j.JobID, c.UserID, N'Tran Van Ung Vien', N'0900000003', N'ungvien01@example.com', N'Uploads/CVs/cv-tran-van-ung-vien.pdf', s.StatusID, N'Ho so moi nop, can xem xet ky nang ASP.NET MVC.', DATEADD(DAY, -3, GETDATE())
FROM dbo.Jobs j
JOIN dbo.Users c ON c.Username = N'ungvien01'
JOIN dbo.ApplicationStatuses s ON s.StatusName = N'Mới nộp'
WHERE j.Title = N'Tuyen lap trinh vien ASP.NET MVC'
  AND NOT EXISTS (SELECT 1 FROM dbo.Applications WHERE JobID = j.JobID AND CandidateEmail = N'ungvien01@example.com');

INSERT INTO dbo.Applications (JobID, CandidateUserID, CandidateName, CandidatePhone, CandidateEmail, CVFilePath, StatusID, HRNote, AppliedDate)
SELECT j.JobID, NULL, N'Le Thi Minh Anh', N'0912345678', N'minhanh@example.com', N'Uploads/CVs/cv-le-thi-minh-anh.pdf', s.StatusID, N'Ung vien co kinh nghiem ban hang.', DATEADD(DAY, -2, GETDATE())
FROM dbo.Jobs j
JOIN dbo.ApplicationStatuses s ON s.StatusName = N'Đang xem xét'
WHERE j.Title = N'Tuyen chuyen vien kinh doanh'
  AND NOT EXISTS (SELECT 1 FROM dbo.Applications WHERE JobID = j.JobID AND CandidateEmail = N'minhanh@example.com');

INSERT INTO dbo.Applications (JobID, CandidateUserID, CandidateName, CandidatePhone, CandidateEmail, CVFilePath, StatusID, HRNote, AppliedDate)
SELECT j.JobID, NULL, N'Pham Quoc Bao', N'0987654321', N'quocbao@example.com', N'Uploads/CVs/cv-pham-quoc-bao.pdf', s.StatusID, N'Da hen phong van vong 1.', DATEADD(DAY, -1, GETDATE())
FROM dbo.Jobs j
JOIN dbo.ApplicationStatuses s ON s.StatusName = N'Mời phỏng vấn'
WHERE j.Title = N'Tuyen thuc tap sinh nhan su'
  AND NOT EXISTS (SELECT 1 FROM dbo.Applications WHERE JobID = j.JobID AND CandidateEmail = N'quocbao@example.com');
GO

INSERT INTO dbo.CandidateFiles (ApplicationID, OriginalFileName, StoredFileName, FilePath, FileExtension, FileSizeKB, UploadedByUserID)
SELECT a.ApplicationID, N'cv-tran-van-ung-vien.pdf', N'cv-tran-van-ung-vien.pdf', N'Uploads/CVs/cv-tran-van-ung-vien.pdf', N'.pdf', 320, a.CandidateUserID
FROM dbo.Applications a
WHERE a.CandidateEmail = N'ungvien01@example.com'
  AND NOT EXISTS (SELECT 1 FROM dbo.CandidateFiles WHERE ApplicationID = a.ApplicationID);

INSERT INTO dbo.CandidateFiles (ApplicationID, OriginalFileName, StoredFileName, FilePath, FileExtension, FileSizeKB, UploadedByUserID)
SELECT a.ApplicationID, N'cv-le-thi-minh-anh.docx', N'cv-le-thi-minh-anh.docx', N'Uploads/CVs/cv-le-thi-minh-anh.docx', N'.docx', 180, NULL
FROM dbo.Applications a
WHERE a.CandidateEmail = N'minhanh@example.com'
  AND NOT EXISTS (SELECT 1 FROM dbo.CandidateFiles WHERE ApplicationID = a.ApplicationID);

INSERT INTO dbo.CandidateFiles (ApplicationID, OriginalFileName, StoredFileName, FilePath, FileExtension, FileSizeKB, UploadedByUserID)
SELECT a.ApplicationID, N'cv-pham-quoc-bao.pdf', N'cv-pham-quoc-bao.pdf', N'Uploads/CVs/cv-pham-quoc-bao.pdf', N'.pdf', 250, NULL
FROM dbo.Applications a
WHERE a.CandidateEmail = N'quocbao@example.com'
  AND NOT EXISTS (SELECT 1 FROM dbo.CandidateFiles WHERE ApplicationID = a.ApplicationID);
GO

INSERT INTO dbo.ApplicationStatusHistories (ApplicationID, OldStatusID, NewStatusID, ChangedByUserID, Note, ChangedAt)
SELECT a.ApplicationID, NULL, a.StatusID, hr.UserID, N'Hệ thống ghi nhận trạng thái ban đầu khi ứng viên nộp hồ sơ.', a.AppliedDate
FROM dbo.Applications a
JOIN dbo.Users hr ON hr.Username = N'hr01'
WHERE NOT EXISTS (SELECT 1 FROM dbo.ApplicationStatusHistories WHERE ApplicationID = a.ApplicationID);
GO

INSERT INTO dbo.Interviews (ApplicationID, InterviewDate, InterviewLocation, InterviewerUserID, Note, Result, CreatedByUserID)
SELECT a.ApplicationID, DATEADD(DAY, 2, GETDATE()), N'Phong hop A101', hr.UserID, N'Phong van truc tiep vong 1.', N'Chua co ket qua', hr.UserID
FROM dbo.Applications a
JOIN dbo.Users hr ON hr.Username = N'hr01'
WHERE a.CandidateEmail = N'quocbao@example.com'
  AND NOT EXISTS (SELECT 1 FROM dbo.Interviews WHERE ApplicationID = a.ApplicationID);
GO

INSERT INTO dbo.AuditLogs (UserID, ActionName, TableName, RecordID, Description, IpAddress)
SELECT u.UserID, N'CREATE_JOB', N'Jobs', j.JobID, N'HR tao tin tuyen dung mau cho demo.', N'127.0.0.1'
FROM dbo.Users u
JOIN dbo.Jobs j ON j.Title = N'Tuyen lap trinh vien ASP.NET MVC'
WHERE u.Username = N'hr01'
  AND NOT EXISTS (SELECT 1 FROM dbo.AuditLogs WHERE ActionName = N'CREATE_JOB' AND TableName = N'Jobs' AND RecordID = j.JobID);

INSERT INTO dbo.AuditLogs (UserID, ActionName, TableName, RecordID, Description, IpAddress)
SELECT u.UserID, N'UPLOAD_CV', N'CandidateFiles', f.CandidateFileID, N'Ung vien upload CV mau cho demo.', N'127.0.0.1'
FROM dbo.Users u
JOIN dbo.CandidateFiles f ON f.FilePath = N'Uploads/CVs/cv-tran-van-ung-vien.pdf'
WHERE u.Username = N'ungvien01'
  AND NOT EXISTS (SELECT 1 FROM dbo.AuditLogs WHERE ActionName = N'UPLOAD_CV' AND TableName = N'CandidateFiles' AND RecordID = f.CandidateFileID);
GO

/* =====================================================
   7. QUICK CHECK QUERIES
   ===================================================== */

SELECT RoleID, RoleName FROM dbo.Roles ORDER BY RoleID;
SELECT UserID, Username, FullName, Email, RoleID, IsActive, FailedLoginCount, LockedUntil FROM dbo.Users ORDER BY UserID;
SELECT JobID, Title, Location, JobType, Deadline, IsActive, IsDeleted FROM dbo.Jobs ORDER BY JobID;
SELECT ApplicationID, JobID, CandidateName, CandidateEmail, StatusID, CVFilePath, AppliedDate FROM dbo.Applications ORDER BY ApplicationID;
SELECT CandidateFileID, ApplicationID, OriginalFileName, FilePath, FileExtension, FileSizeKB FROM dbo.CandidateFiles ORDER BY CandidateFileID;
SELECT HistoryID, ApplicationID, OldStatusID, NewStatusID, ChangedByUserID, ChangedAt FROM dbo.ApplicationStatusHistories ORDER BY HistoryID;
SELECT InterviewID, ApplicationID, InterviewDate, InterviewLocation, Result FROM dbo.Interviews ORDER BY InterviewID;
SELECT AuditLogID, UserID, ActionName, TableName, RecordID, CreatedAt FROM dbo.AuditLogs ORDER BY AuditLogID;
GO
