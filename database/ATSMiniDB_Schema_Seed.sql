/*
  ATSMiniDB - SQL Server schema + sample data
  Muc tieu: Du tot cho do an sinh vien, khong so sai, nhung khong qua nang nhu he thong doanh nghiep that.

  Cong nghe du kien:
  - ASP.NET MVC 5 / .NET Framework
  - Entity Framework 6 Code First from database
  - SQL Server

  Cach dung:
  1. Mo SQL Server Management Studio.
  2. Chay toan bo script nay.
  3. Ung dung ket noi database ATSMiniDB qua connection string ModelDB.

  Luu y quan trong ve mat khau:
  - Script nay khong luu mat khau ro.
  - Mat khau demo van la: 123456
  - PasswordHash trong seed data duoc tao bang SHA2_256(Salt + Password) trong SQL Server.
  - Day la muc demo tot hon plain text cho mon hoc, chua phai chuan production nhu ASP.NET Identity/PBKDF2/bcrypt/Argon2.
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF DB_ID(N'ATSMiniDB') IS NULL
BEGIN
    CREATE DATABASE ATSMiniDB;
END
GO

USE ATSMiniDB;
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

/* =====================================================
   6. SEED DATA
   ===================================================== */

/* Nâng cấp dữ liệu mẫu cũ sang tiếng Việt có dấu trước khi seed.
   Chỉ các giá trị mẫu được cập nhật nên khối này có thể chạy lại an toàn. */
UPDATE dbo.Roles
SET Description = CASE RoleName
    WHEN N'Admin' THEN N'Quản trị hệ thống'
    WHEN N'HR' THEN N'Nhân sự tuyển dụng'
    WHEN N'Candidate' THEN N'Ứng viên'
END
WHERE RoleName IN (N'Admin', N'HR', N'Candidate');

UPDATE dbo.Users
SET FullName = CASE Username
    WHEN N'admin' THEN N'Quản trị viên'
    WHEN N'hr01' THEN N'Nguyễn Thị HR'
    WHEN N'ungvien01' THEN N'Trần Văn Ứng Viên'
END
WHERE Username IN (N'admin', N'hr01', N'ungvien01');

UPDATE dbo.Departments
SET DepartmentName = CASE DepartmentName
        WHEN N'Phong Cong nghe thong tin' THEN N'Phòng Công nghệ thông tin'
        WHEN N'Phong Kinh doanh' THEN N'Phòng Kinh doanh'
        WHEN N'Phong Nhan su' THEN N'Phòng Nhân sự'
        ELSE DepartmentName
    END,
    Description = CASE DepartmentName
        WHEN N'Phong Cong nghe thong tin' THEN N'Phụ trách phát triển phần mềm và hệ thống'
        WHEN N'Phong Kinh doanh' THEN N'Phụ trách bán hàng và chăm sóc khách hàng'
        WHEN N'Phong Nhan su' THEN N'Phụ trách tuyển dụng và hành chính'
        ELSE Description
    END
WHERE DepartmentName IN (N'Phong Cong nghe thong tin', N'Phong Kinh doanh', N'Phong Nhan su');

UPDATE dbo.JobPositions
SET PositionName = CASE PositionName
        WHEN N'Lap trinh vien Web' THEN N'Lập trình viên Web'
        WHEN N'Chuyen vien kinh doanh' THEN N'Chuyên viên kinh doanh'
        WHEN N'Thuc tap sinh nhan su' THEN N'Thực tập sinh nhân sự'
        ELSE PositionName
    END,
    Description = CASE PositionName
        WHEN N'Lap trinh vien Web' THEN N'Phát triển ứng dụng web bằng ASP.NET/C#'
        WHEN N'Chuyen vien kinh doanh' THEN N'Tìm kiếm và chăm sóc khách hàng'
        WHEN N'Thuc tap sinh nhan su' THEN N'Hỗ trợ công tác tuyển dụng và hồ sơ nhân sự'
        ELSE Description
    END
WHERE PositionName IN (N'Lap trinh vien Web', N'Chuyen vien kinh doanh', N'Thuc tap sinh nhan su');

UPDATE dbo.ApplicationStatuses
SET StatusName = CASE StatusName
        WHEN N'Moi nop' THEN N'Mới nộp'
        WHEN N'Dang xem xet' THEN N'Đang xem xét'
        WHEN N'Moi phong van' THEN N'Mời phỏng vấn'
        WHEN N'Dat' THEN N'Đạt'
        WHEN N'Truot' THEN N'Không đạt'
        ELSE StatusName
    END,
    Description = CASE StatusName
        WHEN N'Moi nop' THEN N'Ứng viên vừa nộp hồ sơ'
        WHEN N'Dang xem xet' THEN N'HR đang xem xét hồ sơ'
        WHEN N'Moi phong van' THEN N'Ứng viên được mời phỏng vấn'
        WHEN N'Dat' THEN N'Ứng viên đạt yêu cầu'
        WHEN N'Truot' THEN N'Ứng viên không đạt yêu cầu'
        ELSE Description
    END
WHERE StatusName IN (N'Moi nop', N'Dang xem xet', N'Moi phong van', N'Dat', N'Truot');

UPDATE dbo.Jobs
SET Title = CASE Title
        WHEN N'Tuyen lap trinh vien ASP.NET MVC' THEN N'Tuyển lập trình viên ASP.NET MVC'
        WHEN N'Tuyen chuyen vien kinh doanh' THEN N'Tuyển chuyên viên kinh doanh'
        WHEN N'Tuyen thuc tap sinh nhan su' THEN N'Tuyển thực tập sinh nhân sự'
        ELSE Title
    END,
    Description = CASE Title
        WHEN N'Tuyen lap trinh vien ASP.NET MVC' THEN N'Tham gia phát triển website nội bộ và các ứng dụng quản lý.'
        WHEN N'Tuyen chuyen vien kinh doanh' THEN N'Tìm kiếm khách hàng mới, chăm sóc khách hàng hiện có và báo cáo doanh số.'
        WHEN N'Tuyen thuc tap sinh nhan su' THEN N'Hỗ trợ đăng tin, lọc CV, sắp xếp lịch phỏng vấn và lưu trữ hồ sơ.'
        ELSE Description
    END,
    Requirements = CASE Title
        WHEN N'Tuyen lap trinh vien ASP.NET MVC' THEN N'Biết C#, ASP.NET MVC, SQL Server. Có kiến thức HTML, CSS, JavaScript.'
        WHEN N'Tuyen chuyen vien kinh doanh' THEN N'Giao tiếp tốt, năng động, có khả năng làm việc nhóm.'
        WHEN N'Tuyen thuc tap sinh nhan su' THEN N'Sinh viên năm 3 hoặc năm 4, cẩn thận, biết dùng Word/Excel cơ bản.'
        ELSE Requirements
    END,
    Industry = CASE Industry
        WHEN N'Cong nghe thong tin' THEN N'Công nghệ thông tin'
        WHEN N'Nhan su' THEN N'Nhân sự'
        ELSE Industry
    END,
    SalaryRange = CASE SalaryRange
        WHEN N'8 - 15 trieu' THEN N'8 - 15 triệu'
        WHEN N'7 - 12 trieu' THEN N'7 - 12 triệu'
        WHEN N'Ho tro 2 - 4 trieu' THEN N'Hỗ trợ 2 - 4 triệu'
        ELSE SalaryRange
    END,
    Location = CASE Location
        WHEN N'Cao Lanh, Dong Thap' THEN N'Cao Lãnh, Đồng Tháp'
        WHEN N'Can Tho' THEN N'Cần Thơ'
        ELSE Location
    END,
    JobType = CASE JobType
        WHEN N'Full-time' THEN N'Toàn thời gian'
        WHEN N'Internship' THEN N'Thực tập'
        ELSE JobType
    END
WHERE Title IN (
    N'Tuyen lap trinh vien ASP.NET MVC',
    N'Tuyen chuyen vien kinh doanh',
    N'Tuyen thuc tap sinh nhan su'
);

UPDATE dbo.Applications
SET CandidateName = CASE CandidateEmail
        WHEN N'ungvien01@example.com' THEN N'Trần Văn Ứng Viên'
        WHEN N'minhanh@example.com' THEN N'Lê Thị Minh Anh'
        WHEN N'quocbao@example.com' THEN N'Phạm Quốc Bảo'
        ELSE CandidateName
    END,
    HRNote = CASE CandidateEmail
        WHEN N'ungvien01@example.com' THEN N'Hồ sơ mới nộp, cần xem xét kỹ năng ASP.NET MVC.'
        WHEN N'minhanh@example.com' THEN N'Ứng viên có kinh nghiệm bán hàng.'
        WHEN N'quocbao@example.com' THEN N'Đã hẹn phỏng vấn vòng 1.'
        ELSE HRNote
    END
WHERE CandidateEmail IN (
    N'ungvien01@example.com',
    N'minhanh@example.com',
    N'quocbao@example.com'
);

UPDATE dbo.ApplicationStatusHistories
SET Note = N'Hệ thống ghi nhận trạng thái ban đầu khi ứng viên nộp hồ sơ.'
WHERE Note = N'He thong ghi nhan trang thai ban dau khi ung vien nop ho so.';

UPDATE dbo.Interviews
SET InterviewLocation = CASE
        WHEN InterviewLocation = N'Phong hop A101' THEN N'Phòng họp A101'
        ELSE InterviewLocation
    END,
    Note = CASE
        WHEN Note = N'Phong van truc tiep vong 1.' THEN N'Phỏng vấn trực tiếp vòng 1.'
        ELSE Note
    END,
    Result = CASE
        WHEN Result = N'Chua co ket qua' THEN N'Chưa có kết quả'
        ELSE Result
    END;

UPDATE dbo.AuditLogs
SET Description = CASE Description
    WHEN N'HR tao tin tuyen dung mau cho demo.' THEN N'HR tạo tin tuyển dụng mẫu cho demo.'
    WHEN N'Ung vien upload CV mau cho demo.' THEN N'Ứng viên tải CV mẫu lên để demo.'
    ELSE Description
END
WHERE Description IN (
    N'HR tao tin tuyen dung mau cho demo.',
    N'Ung vien upload CV mau cho demo.'
);
GO

INSERT INTO dbo.Roles (RoleName, Description)
SELECT N'Admin', N'Quản trị hệ thống'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleName = N'Admin');

INSERT INTO dbo.Roles (RoleName, Description)
SELECT N'HR', N'Nhân sự tuyển dụng'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleName = N'HR');

INSERT INTO dbo.Roles (RoleName, Description)
SELECT N'Candidate', N'Ứng viên'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE RoleName = N'Candidate');
GO

DECLARE @DefaultPassword NVARCHAR(50) = N'123456';

INSERT INTO dbo.Users (Username, PasswordHash, PasswordSalt, FullName, Email, Phone, RoleID)
SELECT N'admin',
       CONVERT(NVARCHAR(128), HASHBYTES('SHA2_256', CONVERT(NVARCHAR(4000), N'ATS_DEMO_ADMIN' + @DefaultPassword)), 2),
       N'ATS_DEMO_ADMIN',
       N'Quản trị viên',
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
       N'Nguyễn Thị HR',
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
       N'Trần Văn Ứng Viên',
       N'ungvien01@example.com',
       N'0900000003',
       r.RoleID
FROM dbo.Roles r
WHERE r.RoleName = N'Candidate'
  AND NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'ungvien01');
GO

INSERT INTO dbo.Departments (DepartmentName, Description, CreatedByUserID)
SELECT N'Phòng Công nghệ thông tin', N'Phụ trách phát triển phần mềm và hệ thống', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentName = N'Phòng Công nghệ thông tin');

INSERT INTO dbo.Departments (DepartmentName, Description, CreatedByUserID)
SELECT N'Phòng Kinh doanh', N'Phụ trách bán hàng và chăm sóc khách hàng', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentName = N'Phòng Kinh doanh');

INSERT INTO dbo.Departments (DepartmentName, Description, CreatedByUserID)
SELECT N'Phòng Nhân sự', N'Phụ trách tuyển dụng và hành chính', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentName = N'Phòng Nhân sự');
GO

INSERT INTO dbo.JobPositions (PositionName, Description, CreatedByUserID)
SELECT N'Lập trình viên Web', N'Phát triển ứng dụng web bằng ASP.NET/C#', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.JobPositions WHERE PositionName = N'Lập trình viên Web');

INSERT INTO dbo.JobPositions (PositionName, Description, CreatedByUserID)
SELECT N'Chuyên viên kinh doanh', N'Tìm kiếm và chăm sóc khách hàng', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.JobPositions WHERE PositionName = N'Chuyên viên kinh doanh');

INSERT INTO dbo.JobPositions (PositionName, Description, CreatedByUserID)
SELECT N'Thực tập sinh nhân sự', N'Hỗ trợ công tác tuyển dụng và hồ sơ nhân sự', u.UserID
FROM dbo.Users u
WHERE u.Username = N'admin'
  AND NOT EXISTS (SELECT 1 FROM dbo.JobPositions WHERE PositionName = N'Thực tập sinh nhân sự');
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

INSERT INTO dbo.Jobs (Title, Description, Requirements, DepartmentID, JobPositionID, Industry, SalaryRange, Location, JobType, Deadline, CreatedByUserID, IsActive)
SELECT N'Tuyển lập trình viên ASP.NET MVC',
       N'Tham gia phát triển website nội bộ và các ứng dụng quản lý.',
       N'Biết C#, ASP.NET MVC, SQL Server. Có kiến thức HTML, CSS, JavaScript.',
       d.DepartmentID, p.JobPositionID, N'Công nghệ thông tin', N'8 - 15 triệu', N'Cao Lãnh, Đồng Tháp', N'Toàn thời gian', DATEADD(DAY, 30, CAST(GETDATE() AS DATE)), u.UserID, 1
FROM dbo.Departments d
JOIN dbo.JobPositions p ON p.PositionName = N'Lập trình viên Web'
JOIN dbo.Users u ON u.Username = N'hr01'
WHERE d.DepartmentName = N'Phòng Công nghệ thông tin'
  AND NOT EXISTS (SELECT 1 FROM dbo.Jobs WHERE Title = N'Tuyển lập trình viên ASP.NET MVC');

INSERT INTO dbo.Jobs (Title, Description, Requirements, DepartmentID, JobPositionID, Industry, SalaryRange, Location, JobType, Deadline, CreatedByUserID, IsActive)
SELECT N'Tuyển chuyên viên kinh doanh',
       N'Tìm kiếm khách hàng mới, chăm sóc khách hàng hiện có và báo cáo doanh số.',
       N'Giao tiếp tốt, năng động, có khả năng làm việc nhóm.',
       d.DepartmentID, p.JobPositionID, N'Kinh doanh', N'7 - 12 triệu', N'Cần Thơ', N'Toàn thời gian', DATEADD(DAY, 25, CAST(GETDATE() AS DATE)), u.UserID, 1
FROM dbo.Departments d
JOIN dbo.JobPositions p ON p.PositionName = N'Chuyên viên kinh doanh'
JOIN dbo.Users u ON u.Username = N'hr01'
WHERE d.DepartmentName = N'Phòng Kinh doanh'
  AND NOT EXISTS (SELECT 1 FROM dbo.Jobs WHERE Title = N'Tuyển chuyên viên kinh doanh');

INSERT INTO dbo.Jobs (Title, Description, Requirements, DepartmentID, JobPositionID, Industry, SalaryRange, Location, JobType, Deadline, CreatedByUserID, IsActive)
SELECT N'Tuyển thực tập sinh nhân sự',
       N'Hỗ trợ đăng tin, lọc CV, sắp xếp lịch phỏng vấn và lưu trữ hồ sơ.',
       N'Sinh viên năm 3 hoặc năm 4, cẩn thận, biết dùng Word/Excel cơ bản.',
       d.DepartmentID, p.JobPositionID, N'Nhân sự', N'Hỗ trợ 2 - 4 triệu', N'Cao Lãnh, Đồng Tháp', N'Thực tập', DATEADD(DAY, 20, CAST(GETDATE() AS DATE)), u.UserID, 1
FROM dbo.Departments d
JOIN dbo.JobPositions p ON p.PositionName = N'Thực tập sinh nhân sự'
JOIN dbo.Users u ON u.Username = N'hr01'
WHERE d.DepartmentName = N'Phòng Nhân sự'
  AND NOT EXISTS (SELECT 1 FROM dbo.Jobs WHERE Title = N'Tuyển thực tập sinh nhân sự');
GO

INSERT INTO dbo.Applications (JobID, CandidateUserID, CandidateName, CandidatePhone, CandidateEmail, CVFilePath, StatusID, HRNote, AppliedDate)
SELECT j.JobID, c.UserID, N'Trần Văn Ứng Viên', N'0900000003', N'ungvien01@example.com', N'Uploads/CVs/cv-tran-van-ung-vien.pdf', s.StatusID, N'Hồ sơ mới nộp, cần xem xét kỹ năng ASP.NET MVC.', DATEADD(DAY, -3, GETDATE())
FROM dbo.Jobs j
JOIN dbo.Users c ON c.Username = N'ungvien01'
JOIN dbo.ApplicationStatuses s ON s.StatusName = N'Mới nộp'
WHERE j.Title = N'Tuyển lập trình viên ASP.NET MVC'
  AND NOT EXISTS (SELECT 1 FROM dbo.Applications WHERE JobID = j.JobID AND CandidateEmail = N'ungvien01@example.com');

INSERT INTO dbo.Applications (JobID, CandidateUserID, CandidateName, CandidatePhone, CandidateEmail, CVFilePath, StatusID, HRNote, AppliedDate)
SELECT j.JobID, NULL, N'Lê Thị Minh Anh', N'0912345678', N'minhanh@example.com', N'Uploads/CVs/cv-le-thi-minh-anh.docx', s.StatusID, N'Ứng viên có kinh nghiệm bán hàng.', DATEADD(DAY, -2, GETDATE())
FROM dbo.Jobs j
JOIN dbo.ApplicationStatuses s ON s.StatusName = N'Đang xem xét'
WHERE j.Title = N'Tuyển chuyên viên kinh doanh'
  AND NOT EXISTS (SELECT 1 FROM dbo.Applications WHERE JobID = j.JobID AND CandidateEmail = N'minhanh@example.com');

INSERT INTO dbo.Applications (JobID, CandidateUserID, CandidateName, CandidatePhone, CandidateEmail, CVFilePath, StatusID, HRNote, AppliedDate)
SELECT j.JobID, NULL, N'Phạm Quốc Bảo', N'0987654321', N'quocbao@example.com', N'Uploads/CVs/cv-pham-quoc-bao.pdf', s.StatusID, N'Đã hẹn phỏng vấn vòng 1.', DATEADD(DAY, -1, GETDATE())
FROM dbo.Jobs j
JOIN dbo.ApplicationStatuses s ON s.StatusName = N'Mời phỏng vấn'
WHERE j.Title = N'Tuyển thực tập sinh nhân sự'
  AND NOT EXISTS (SELECT 1 FROM dbo.Applications WHERE JobID = j.JobID AND CandidateEmail = N'quocbao@example.com');
GO

UPDATE dbo.Applications
SET CVFilePath = N'Uploads/CVs/cv-le-thi-minh-anh.docx'
WHERE CandidateEmail = N'minhanh@example.com'
  AND CVFilePath = N'Uploads/CVs/cv-le-thi-minh-anh.pdf';
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
SELECT a.ApplicationID, DATEADD(DAY, 2, GETDATE()), N'Phòng họp A101', hr.UserID, N'Phỏng vấn trực tiếp vòng 1.', N'Chưa có kết quả', hr.UserID
FROM dbo.Applications a
JOIN dbo.Users hr ON hr.Username = N'hr01'
WHERE a.CandidateEmail = N'quocbao@example.com'
  AND NOT EXISTS (SELECT 1 FROM dbo.Interviews WHERE ApplicationID = a.ApplicationID);
GO

INSERT INTO dbo.AuditLogs (UserID, ActionName, TableName, RecordID, Description, IpAddress)
SELECT u.UserID, N'CREATE_JOB', N'Jobs', j.JobID, N'HR tạo tin tuyển dụng mẫu cho demo.', N'127.0.0.1'
FROM dbo.Users u
JOIN dbo.Jobs j ON j.Title = N'Tuyển lập trình viên ASP.NET MVC'
WHERE u.Username = N'hr01'
  AND NOT EXISTS (SELECT 1 FROM dbo.AuditLogs WHERE ActionName = N'CREATE_JOB' AND TableName = N'Jobs' AND RecordID = j.JobID);

INSERT INTO dbo.AuditLogs (UserID, ActionName, TableName, RecordID, Description, IpAddress)
SELECT u.UserID, N'UPLOAD_CV', N'CandidateFiles', f.CandidateFileID, N'Ứng viên tải CV mẫu lên để demo.', N'127.0.0.1'
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
