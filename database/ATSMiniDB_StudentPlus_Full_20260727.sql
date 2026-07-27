-- ATSMiniDB_StudentPlus - full schema and data export
-- Generated: 2026-07-27
-- Requires SQL Server 2019 (15.x) or newer.
-- Safety: this script stops if the target database already exists; it never overwrites an existing database.
USE [master]
GO
IF DB_ID(N'ATSMiniDB_StudentPlus') IS NOT NULL
    THROW 50001, N'Target database already exists. Rename or remove it before importing this script.', 1;
GO
CREATE DATABASE [ATSMiniDB_StudentPlus]
GO
USE [ATSMiniDB_StudentPlus]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Applications](
	[ApplicationID] [int] IDENTITY(1,1) NOT NULL,
	[JobID] [int] NOT NULL,
	[CandidateUserID] [int] NULL,
	[CandidateName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CandidatePhone] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CandidateEmail] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CVFilePath] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StatusID] [int] NOT NULL,
	[HRNote] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AppliedDate] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NULL,
	[UpdatedByUserID] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[ApplicationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ApplicationStatuses](
	[StatusID] [int] IDENTITY(1,1) NOT NULL,
	[StatusName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DisplayOrder] [int] NOT NULL,
	[IsFinal] [bit] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[StatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED
(
	[StatusName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[ApplicationStatusHistories](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[OldStatusID] [int] NULL,
	[NewStatusID] [int] NOT NULL,
	[ChangedByUserID] [int] NULL,
	[ChangedAt] [datetime] NOT NULL,
	[Note] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AuditLogs](
	[AuditLogID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[ActionName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TableName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RecordID] [int] NULL,
	[Description] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedAt] [datetime] NOT NULL,
	[IpAddress] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[AuditLogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[CandidateFiles](
	[CandidateFileID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[OriginalFileName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[StoredFileName] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FilePath] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileExtension] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FileSizeKB] [int] NULL,
	[UploadedAt] [datetime] NOT NULL,
	[UploadedByUserID] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[CandidateFileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Departments](
	[DepartmentID] [int] IDENTITY(1,1) NOT NULL,
	[DepartmentName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[CreatedByUserID] [int] NULL,
	[UpdatedAt] [datetime] NULL,
	[UpdatedByUserID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[DepartmentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED
(
	[DepartmentName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Interviews](
	[InterviewID] [int] IDENTITY(1,1) NOT NULL,
	[ApplicationID] [int] NOT NULL,
	[InterviewDate] [datetime] NOT NULL,
	[InterviewLocation] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[InterviewerUserID] [int] NULL,
	[Note] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Result] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CreatedAt] [datetime] NOT NULL,
	[CreatedByUserID] [int] NULL,
	[UpdatedAt] [datetime] NULL,
	[UpdatedByUserID] [int] NULL,
	[IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[InterviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[JobPositions](
	[JobPositionID] [int] IDENTITY(1,1) NOT NULL,
	[PositionName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[CreatedByUserID] [int] NULL,
	[UpdatedAt] [datetime] NULL,
	[UpdatedByUserID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[JobPositionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED
(
	[PositionName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Jobs](
	[JobID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Requirements] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DepartmentID] [int] NOT NULL,
	[JobPositionID] [int] NOT NULL,
	[Industry] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SalaryRange] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Location] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[JobType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Deadline] [date] NULL,
	[IsActive] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[CreatedByUserID] [int] NULL,
	[UpdatedAt] [datetime] NULL,
	[UpdatedByUserID] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[JobID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Notifications](
	[NotificationID] [int] IDENTITY(1,1) NOT NULL,
	[RecipientUserID] [int] NOT NULL,
	[ApplicationID] [int] NULL,
	[NotificationType] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Title] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Message] [nvarchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[ReadAt] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[NotificationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Roles](
	[RoleID] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Description] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IsActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[RoleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED
(
	[RoleName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SavedJobs](
	[SavedJobID] [int] IDENTITY(1,1) NOT NULL,
	[CandidateUserID] [int] NOT NULL,
	[JobID] [int] NOT NULL,
	[SavedAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[SavedJobID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PasswordHash] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PasswordSalt] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FullName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Email] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Phone] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RoleID] [int] NOT NULL,
	[FailedLoginCount] [int] NOT NULL,
	[LockedUntil] [datetime] NULL,
	[LastLoginAt] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[UpdatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET ANSI_PADDING ON

CREATE NONCLUSTERED INDEX [IX_Applications_Email] ON [dbo].[Applications]
(
	[CandidateEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_Applications_Job_Status] ON [dbo].[Applications]
(
	[JobID] ASC,
	[StatusID] ASC,
	[IsDeleted] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [UX_Applications_Job_Candidate] ON [dbo].[Applications]
(
	[JobID] ASC,
	[CandidateUserID] ASC
)
WHERE ([CandidateUserID] IS NOT NULL AND [IsDeleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UX_Applications_Job_Email] ON [dbo].[Applications]
(
	[JobID] ASC,
	[CandidateEmail] ASC
)
WHERE ([IsDeleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_Interviews_Date] ON [dbo].[Interviews]
(
	[InterviewDate] ASC,
	[IsDeleted] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_Jobs_Active_Deadline] ON [dbo].[Jobs]
(
	[IsActive] ASC,
	[IsDeleted] ASC,
	[Deadline] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_Notifications_Recipient_Read_Created] ON [dbo].[Notifications]
(
	[RecipientUserID] ASC,
	[ReadAt] ASC,
	[CreatedAt] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
SET ANSI_PADDING ON

CREATE UNIQUE NONCLUSTERED INDEX [UX_Notifications_Application_Recipient_Type] ON [dbo].[Notifications]
(
	[ApplicationID] ASC,
	[RecipientUserID] ASC,
	[NotificationType] ASC
)
WHERE ([ApplicationID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [UX_SavedJobs_Candidate_Job] ON [dbo].[SavedJobs]
(
	[CandidateUserID] ASC,
	[JobID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
ALTER TABLE [dbo].[Applications] ADD  CONSTRAINT [DF_Applications_AppliedDate]  DEFAULT (getdate()) FOR [AppliedDate]
ALTER TABLE [dbo].[Applications] ADD  CONSTRAINT [DF_Applications_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE [dbo].[ApplicationStatuses] ADD  CONSTRAINT [DF_ApplicationStatuses_DisplayOrder]  DEFAULT ((0)) FOR [DisplayOrder]
ALTER TABLE [dbo].[ApplicationStatuses] ADD  CONSTRAINT [DF_ApplicationStatuses_IsFinal]  DEFAULT ((0)) FOR [IsFinal]
ALTER TABLE [dbo].[ApplicationStatusHistories] ADD  CONSTRAINT [DF_ApplicationStatusHistories_ChangedAt]  DEFAULT (getdate()) FOR [ChangedAt]
ALTER TABLE [dbo].[AuditLogs] ADD  CONSTRAINT [DF_AuditLogs_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE [dbo].[CandidateFiles] ADD  CONSTRAINT [DF_CandidateFiles_UploadedAt]  DEFAULT (getdate()) FOR [UploadedAt]
ALTER TABLE [dbo].[CandidateFiles] ADD  CONSTRAINT [DF_CandidateFiles_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE [dbo].[Departments] ADD  CONSTRAINT [DF_Departments_IsActive]  DEFAULT ((1)) FOR [IsActive]
ALTER TABLE [dbo].[Departments] ADD  CONSTRAINT [DF_Departments_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE [dbo].[Departments] ADD  CONSTRAINT [DF_Departments_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE [dbo].[Interviews] ADD  CONSTRAINT [DF_Interviews_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE [dbo].[Interviews] ADD  CONSTRAINT [DF_Interviews_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE [dbo].[JobPositions] ADD  CONSTRAINT [DF_JobPositions_IsActive]  DEFAULT ((1)) FOR [IsActive]
ALTER TABLE [dbo].[JobPositions] ADD  CONSTRAINT [DF_JobPositions_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE [dbo].[JobPositions] ADD  CONSTRAINT [DF_JobPositions_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE [dbo].[Jobs] ADD  CONSTRAINT [DF_Jobs_IsActive]  DEFAULT ((1)) FOR [IsActive]
ALTER TABLE [dbo].[Jobs] ADD  CONSTRAINT [DF_Jobs_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE [dbo].[Jobs] ADD  CONSTRAINT [DF_Jobs_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE [dbo].[Notifications] ADD  CONSTRAINT [DF_Notifications_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE [dbo].[Roles] ADD  CONSTRAINT [DF_Roles_IsActive]  DEFAULT ((1)) FOR [IsActive]
ALTER TABLE [dbo].[SavedJobs] ADD  CONSTRAINT [DF_SavedJobs_SavedAt]  DEFAULT (getdate()) FOR [SavedAt]
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_FailedLoginCount]  DEFAULT ((0)) FOR [FailedLoginCount]
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsActive]  DEFAULT ((1)) FOR [IsActive]
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE [dbo].[Applications]  WITH CHECK ADD  CONSTRAINT [FK_Applications_CandidateUser] FOREIGN KEY([CandidateUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Applications] CHECK CONSTRAINT [FK_Applications_CandidateUser]
ALTER TABLE [dbo].[Applications]  WITH CHECK ADD  CONSTRAINT [FK_Applications_Jobs] FOREIGN KEY([JobID])
REFERENCES [dbo].[Jobs] ([JobID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Applications] CHECK CONSTRAINT [FK_Applications_Jobs]
ALTER TABLE [dbo].[Applications]  WITH CHECK ADD  CONSTRAINT [FK_Applications_Statuses] FOREIGN KEY([StatusID])
REFERENCES [dbo].[ApplicationStatuses] ([StatusID])
ALTER TABLE [dbo].[Applications] CHECK CONSTRAINT [FK_Applications_Statuses]
ALTER TABLE [dbo].[Applications]  WITH CHECK ADD  CONSTRAINT [FK_Applications_UpdatedBy] FOREIGN KEY([UpdatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Applications] CHECK CONSTRAINT [FK_Applications_UpdatedBy]
ALTER TABLE [dbo].[ApplicationStatusHistories]  WITH CHECK ADD  CONSTRAINT [FK_StatusHistories_Applications] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Applications] ([ApplicationID])
ON DELETE CASCADE
ALTER TABLE [dbo].[ApplicationStatusHistories] CHECK CONSTRAINT [FK_StatusHistories_Applications]
ALTER TABLE [dbo].[ApplicationStatusHistories]  WITH CHECK ADD  CONSTRAINT [FK_StatusHistories_ChangedBy] FOREIGN KEY([ChangedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[ApplicationStatusHistories] CHECK CONSTRAINT [FK_StatusHistories_ChangedBy]
ALTER TABLE [dbo].[ApplicationStatusHistories]  WITH CHECK ADD  CONSTRAINT [FK_StatusHistories_NewStatus] FOREIGN KEY([NewStatusID])
REFERENCES [dbo].[ApplicationStatuses] ([StatusID])
ALTER TABLE [dbo].[ApplicationStatusHistories] CHECK CONSTRAINT [FK_StatusHistories_NewStatus]
ALTER TABLE [dbo].[ApplicationStatusHistories]  WITH CHECK ADD  CONSTRAINT [FK_StatusHistories_OldStatus] FOREIGN KEY([OldStatusID])
REFERENCES [dbo].[ApplicationStatuses] ([StatusID])
ALTER TABLE [dbo].[ApplicationStatusHistories] CHECK CONSTRAINT [FK_StatusHistories_OldStatus]
ALTER TABLE [dbo].[AuditLogs]  WITH CHECK ADD  CONSTRAINT [FK_AuditLogs_Users] FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[AuditLogs] CHECK CONSTRAINT [FK_AuditLogs_Users]
ALTER TABLE [dbo].[CandidateFiles]  WITH CHECK ADD  CONSTRAINT [FK_CandidateFiles_Applications] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Applications] ([ApplicationID])
ON DELETE CASCADE
ALTER TABLE [dbo].[CandidateFiles] CHECK CONSTRAINT [FK_CandidateFiles_Applications]
ALTER TABLE [dbo].[CandidateFiles]  WITH CHECK ADD  CONSTRAINT [FK_CandidateFiles_UploadedBy] FOREIGN KEY([UploadedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[CandidateFiles] CHECK CONSTRAINT [FK_CandidateFiles_UploadedBy]
ALTER TABLE [dbo].[Departments]  WITH CHECK ADD  CONSTRAINT [FK_Departments_CreatedBy] FOREIGN KEY([CreatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Departments] CHECK CONSTRAINT [FK_Departments_CreatedBy]
ALTER TABLE [dbo].[Departments]  WITH CHECK ADD  CONSTRAINT [FK_Departments_UpdatedBy] FOREIGN KEY([UpdatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Departments] CHECK CONSTRAINT [FK_Departments_UpdatedBy]
ALTER TABLE [dbo].[Interviews]  WITH CHECK ADD  CONSTRAINT [FK_Interviews_Applications] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Applications] ([ApplicationID])
ON DELETE CASCADE
ALTER TABLE [dbo].[Interviews] CHECK CONSTRAINT [FK_Interviews_Applications]
ALTER TABLE [dbo].[Interviews]  WITH CHECK ADD  CONSTRAINT [FK_Interviews_CreatedBy] FOREIGN KEY([CreatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Interviews] CHECK CONSTRAINT [FK_Interviews_CreatedBy]
ALTER TABLE [dbo].[Interviews]  WITH CHECK ADD  CONSTRAINT [FK_Interviews_Interviewer] FOREIGN KEY([InterviewerUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Interviews] CHECK CONSTRAINT [FK_Interviews_Interviewer]
ALTER TABLE [dbo].[Interviews]  WITH CHECK ADD  CONSTRAINT [FK_Interviews_UpdatedBy] FOREIGN KEY([UpdatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Interviews] CHECK CONSTRAINT [FK_Interviews_UpdatedBy]
ALTER TABLE [dbo].[JobPositions]  WITH CHECK ADD  CONSTRAINT [FK_JobPositions_CreatedBy] FOREIGN KEY([CreatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[JobPositions] CHECK CONSTRAINT [FK_JobPositions_CreatedBy]
ALTER TABLE [dbo].[JobPositions]  WITH CHECK ADD  CONSTRAINT [FK_JobPositions_UpdatedBy] FOREIGN KEY([UpdatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[JobPositions] CHECK CONSTRAINT [FK_JobPositions_UpdatedBy]
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_CreatedBy] FOREIGN KEY([CreatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_CreatedBy]
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_Departments] FOREIGN KEY([DepartmentID])
REFERENCES [dbo].[Departments] ([DepartmentID])
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_Departments]
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_JobPositions] FOREIGN KEY([JobPositionID])
REFERENCES [dbo].[JobPositions] ([JobPositionID])
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_JobPositions]
ALTER TABLE [dbo].[Jobs]  WITH CHECK ADD  CONSTRAINT [FK_Jobs_UpdatedBy] FOREIGN KEY([UpdatedByUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Jobs] CHECK CONSTRAINT [FK_Jobs_UpdatedBy]
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_Notifications_Application] FOREIGN KEY([ApplicationID])
REFERENCES [dbo].[Applications] ([ApplicationID])
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_Notifications_Application]
ALTER TABLE [dbo].[Notifications]  WITH CHECK ADD  CONSTRAINT [FK_Notifications_Recipient] FOREIGN KEY([RecipientUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_Notifications_Recipient]
ALTER TABLE [dbo].[SavedJobs]  WITH CHECK ADD  CONSTRAINT [FK_SavedJobs_Candidate] FOREIGN KEY([CandidateUserID])
REFERENCES [dbo].[Users] ([UserID])
ALTER TABLE [dbo].[SavedJobs] CHECK CONSTRAINT [FK_SavedJobs_Candidate]
ALTER TABLE [dbo].[SavedJobs]  WITH CHECK ADD  CONSTRAINT [FK_SavedJobs_Job] FOREIGN KEY([JobID])
REFERENCES [dbo].[Jobs] ([JobID])
ON DELETE CASCADE
ALTER TABLE [dbo].[SavedJobs] CHECK CONSTRAINT [FK_SavedJobs_Job]
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_Roles] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Roles] ([RoleID])
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_Roles]
ALTER TABLE [dbo].[CandidateFiles]  WITH CHECK ADD  CONSTRAINT [CK_CandidateFiles_Extension] CHECK  (([FileExtension]=N'.docx' OR [FileExtension]=N'.doc' OR [FileExtension]=N'.pdf'))
ALTER TABLE [dbo].[CandidateFiles] CHECK CONSTRAINT [CK_CandidateFiles_Extension]
ALTER TABLE [dbo].[CandidateFiles]  WITH CHECK ADD  CONSTRAINT [CK_CandidateFiles_Size] CHECK  (([FileSizeKB] IS NULL OR [FileSizeKB]>(0) AND [FileSizeKB]<=(5120)))
ALTER TABLE [dbo].[CandidateFiles] CHECK CONSTRAINT [CK_CandidateFiles_Size]
-- Disable constraints while preserving the exported identity values and relationships.
ALTER TABLE [dbo].[Applications] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[ApplicationStatuses] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[ApplicationStatusHistories] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[AuditLogs] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[CandidateFiles] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Departments] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Interviews] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[JobPositions] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Jobs] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Notifications] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Roles] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[SavedJobs] NOCHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Users] NOCHECK CONSTRAINT ALL
GO
-- Data for [dbo].[Applications]
SET IDENTITY_INSERT [dbo].[Applications] ON

INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (1, 1, 3, N'Tran Van Ung Vien', N'0900000003', N'ungvien01@example.com', N'Uploads/CVs/cv-tran-van-ung-vien.pdf', 6, N'Ho so moi nop, can xem xet ky nang ASP.NET MVC.', CAST(N'2026-07-02T19:10:00.187' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (2, 2, NULL, N'Le Thi Minh Anh', N'0912345678', N'minhanh@example.com', N'Uploads/CVs/cv-le-thi-minh-anh.pdf', 8, N'Ung vien co kinh nghiem ban hang.', CAST(N'2026-07-03T19:10:00.190' AS DateTime), CAST(N'2026-07-26T19:41:04.400' AS DateTime), 1, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (3, 3, NULL, N'Pham Quoc Bao', N'0987654321', N'quocbao@example.com', N'Uploads/CVs/cv-pham-quoc-bao.pdf', 8, N'Da hen phong van vong 1.', CAST(N'2026-07-04T19:10:00.190' AS DateTime), CAST(N'2026-07-26T10:55:25.317' AS DateTime), 1, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (6, 2, 3, N'Tran Van Ung Vien1', N'0900000003', N'ungvien01@example.com', N'Uploads/CVs/c0972927fa91471089d43a7dc04cc7be.pdf', 8, NULL, CAST(N'2026-07-25T19:03:41.943' AS DateTime), CAST(N'2026-07-26T10:51:46.393' AS DateTime), 1, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (7, 6, 20, N'Nguyễn Minh Anh', N'0911000002', N'ungvien02@example.com', NULL, 9, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.iiu', CAST(N'2026-07-26T15:36:08.677' AS DateTime), CAST(N'2026-07-26T21:13:30.033' AS DateTime), 2, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (8, 7, 21, N'Trần Quốc Bảo', N'0911000003', N'ungvien03@example.com', NULL, 7, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-26T11:36:08.677' AS DateTime), CAST(N'2026-07-26T19:40:14.100' AS DateTime), 1, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (9, 8, 22, N'Lê Hoàng Duy', N'0911000004', N'ungvien04@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-26T07:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (10, 9, 23, N'Phạm Thu Hà', N'0911000005', N'ungvien05@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-26T03:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (11, 10, 24, N'Võ Gia Hân', N'0911000006', N'ungvien06@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-25T23:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (12, 11, 25, N'Đặng Tuấn Kiệt', N'0911000007', N'ungvien07@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-25T19:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (13, 12, 26, N'Bùi Ngọc Lan', N'0911000008', N'ungvien08@example.com', NULL, 8, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-25T15:36:08.677' AS DateTime), CAST(N'2026-07-26T19:40:45.013' AS DateTime), 1, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (14, 13, 27, N'Nguyễn Đức Long', N'0911000009', N'ungvien09@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-25T11:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (15, 14, 28, N'Trần Khánh Linh', N'0911000010', N'ungvien10@example.com', NULL, 8, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-25T07:36:08.677' AS DateTime), CAST(N'2026-07-26T19:43:15.757' AS DateTime), 1, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (16, 15, 29, N'Lê Nhật Minh', N'0911000011', N'ungvien11@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-25T03:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (17, 16, 30, N'Phạm Quỳnh Như', N'0911000012', N'ungvien12@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-24T23:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (18, 17, 31, N'Võ Thành Phát', N'0911000013', N'ungvien13@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-24T19:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (19, 18, 32, N'Đặng Yến Nhi', N'0911000014', N'ungvien14@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-24T15:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (20, 19, 33, N'Bùi Anh Thư', N'0911000015', N'ungvien15@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-24T11:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (21, 20, 34, N'Nguyễn Hải Yến', N'0911000016', N'ungvien16@example.com', NULL, 6, N'Hồ sơ dữ liệu mẫu; chưa đính kèm tệp CV.', CAST(N'2026-07-24T07:36:08.677' AS DateTime), NULL, NULL, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (22, 20, 20, N'Nguyễn Minh Anh', N'0911000002', N'ungvien02@example.com', N'Uploads/CVs/f550b2ece58d45cdb1361cfe4e13e547.pdf', 8, N'cần xem lại', CAST(N'2026-07-26T20:36:26.557' AS DateTime), CAST(N'2026-07-26T20:40:04.970' AS DateTime), 2, 0)
INSERT [dbo].[Applications] ([ApplicationID], [JobID], [CandidateUserID], [CandidateName], [CandidatePhone], [CandidateEmail], [CVFilePath], [StatusID], [HRNote], [AppliedDate], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (23, 33, 20, N'Ứng viên Demo', N'0911000002', N'candidate.demo@example.com', N'Uploads/CVs/b0e3550ef5c842e39785895323387be0.pdf', 11, N'Ứng viên phù hợp kỹ năng kiểm thử cơ bản.', CAST(N'2026-07-27T13:36:46.507' AS DateTime), CAST(N'2026-07-27T13:49:00.280' AS DateTime), 2, 0)
SET IDENTITY_INSERT [dbo].[Applications] OFF
-- Data for [dbo].[ApplicationStatuses]
SET IDENTITY_INSERT [dbo].[ApplicationStatuses] ON

INSERT [dbo].[ApplicationStatuses] ([StatusID], [StatusName], [Description], [DisplayOrder], [IsFinal]) VALUES (6, N'Mới nộp', N'Ứng viên vừa nộp hồ sơ', 1, 0)
INSERT [dbo].[ApplicationStatuses] ([StatusID], [StatusName], [Description], [DisplayOrder], [IsFinal]) VALUES (7, N'Đang xem xét', N'HR đang xem xét hồ sơ', 2, 0)
INSERT [dbo].[ApplicationStatuses] ([StatusID], [StatusName], [Description], [DisplayOrder], [IsFinal]) VALUES (8, N'Mời phỏng vấn', N'Ứng viên được mời phỏng vấn', 3, 0)
INSERT [dbo].[ApplicationStatuses] ([StatusID], [StatusName], [Description], [DisplayOrder], [IsFinal]) VALUES (9, N'Đạt', N'Ứng viên đạt yêu cầu', 4, 1)
INSERT [dbo].[ApplicationStatuses] ([StatusID], [StatusName], [Description], [DisplayOrder], [IsFinal]) VALUES (11, N'Không đạt', N'Ứng viên không đạt yêu cầu', 5, 1)
SET IDENTITY_INSERT [dbo].[ApplicationStatuses] OFF
-- Data for [dbo].[ApplicationStatusHistories]
SET IDENTITY_INSERT [dbo].[ApplicationStatusHistories] ON

INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (1, 1, NULL, 6, 2, CAST(N'2026-07-02T19:10:00.187' AS DateTime), N'He thong ghi nhan trang thai ban dau khi ung vien nop ho so.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (2, 2, NULL, 7, 2, CAST(N'2026-07-03T19:10:00.190' AS DateTime), N'He thong ghi nhan trang thai ban dau khi ung vien nop ho so.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (3, 3, NULL, 8, 2, CAST(N'2026-07-04T19:10:00.190' AS DateTime), N'He thong ghi nhan trang thai ban dau khi ung vien nop ho so.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (6, 6, NULL, 6, 3, CAST(N'2026-07-25T19:03:41.943' AS DateTime), N'Ứng viên nộp hồ sơ.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (7, 6, 6, 8, 1, CAST(N'2026-07-26T10:51:46.393' AS DateTime), N'HR cập nhật trạng thái hồ sơ.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (8, 7, NULL, 6, 20, CAST(N'2026-07-26T15:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (9, 8, NULL, 6, 21, CAST(N'2026-07-26T11:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (10, 9, NULL, 6, 22, CAST(N'2026-07-26T07:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (11, 10, NULL, 6, 23, CAST(N'2026-07-26T03:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (12, 11, NULL, 6, 24, CAST(N'2026-07-25T23:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (13, 12, NULL, 6, 25, CAST(N'2026-07-25T19:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (14, 13, NULL, 6, 26, CAST(N'2026-07-25T15:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (15, 14, NULL, 6, 27, CAST(N'2026-07-25T11:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (16, 15, NULL, 6, 28, CAST(N'2026-07-25T07:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (17, 16, NULL, 6, 29, CAST(N'2026-07-25T03:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (18, 17, NULL, 6, 30, CAST(N'2026-07-24T23:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (19, 18, NULL, 6, 31, CAST(N'2026-07-24T19:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (20, 19, NULL, 6, 32, CAST(N'2026-07-24T15:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (21, 20, NULL, 6, 33, CAST(N'2026-07-24T11:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (22, 21, NULL, 6, 34, CAST(N'2026-07-24T07:36:08.710' AS DateTime), N'Ứng viên nộp hồ sơ dữ liệu mẫu.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (23, 8, 6, 7, 1, CAST(N'2026-07-26T19:40:14.100' AS DateTime), N'HR cập nhật trạng thái hồ sơ.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (24, 13, 6, 8, 1, CAST(N'2026-07-26T19:40:45.013' AS DateTime), N'HR cập nhật trạng thái hồ sơ.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (25, 2, 7, 8, 1, CAST(N'2026-07-26T19:41:04.400' AS DateTime), N'HR cập nhật trạng thái hồ sơ.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (26, 15, 6, 8, 1, CAST(N'2026-07-26T19:43:15.757' AS DateTime), N'Tự động chuyển trạng thái khi HR tạo lịch phỏng vấn.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (27, 22, NULL, 6, 20, CAST(N'2026-07-26T20:36:26.557' AS DateTime), N'Ứng viên nộp hồ sơ.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (28, 22, 6, 7, 2, CAST(N'2026-07-26T20:38:30.580' AS DateTime), N'grgrgr')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (29, 22, 7, 8, 2, CAST(N'2026-07-26T20:40:04.970' AS DateTime), N'HR cập nhật trạng thái hồ sơ.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (30, 7, 6, 7, 2, CAST(N'2026-07-26T20:46:49.877' AS DateTime), N'ceeede')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (31, 7, 7, 8, 2, CAST(N'2026-07-26T20:47:10.683' AS DateTime), N'feffefefe')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (32, 7, 8, 9, 2, CAST(N'2026-07-26T20:50:47.893' AS DateTime), N'tui đang kiểm tra')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (33, 7, 9, 8, 2, CAST(N'2026-07-26T20:57:10.453' AS DateTime), N'cần chỉnh lại')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (34, 7, 8, 9, 2, CAST(N'2026-07-26T21:13:30.033' AS DateTime), N'Đồng bộ trạng thái từ kết quả phỏng vấn.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (35, 23, NULL, 6, 20, CAST(N'2026-07-27T13:36:46.507' AS DateTime), N'Ứng viên nộp hồ sơ.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (36, 23, 6, 7, 2, CAST(N'2026-07-27T13:41:05.633' AS DateTime), N'Đã kiểm tra CV, chuyển sang bước sàng lọc.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (37, 23, 7, 8, 2, CAST(N'2026-07-27T13:45:57.620' AS DateTime), N'Tự động chuyển trạng thái khi HR tạo lịch phỏng vấn.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (38, 23, 8, 9, 2, CAST(N'2026-07-27T13:47:47.020' AS DateTime), N'Đồng bộ trạng thái từ kết quả phỏng vấn.')
INSERT [dbo].[ApplicationStatusHistories] ([HistoryID], [ApplicationID], [OldStatusID], [NewStatusID], [ChangedByUserID], [ChangedAt], [Note]) VALUES (39, 23, 9, 11, 2, CAST(N'2026-07-27T13:49:00.280' AS DateTime), N'Đồng bộ trạng thái từ kết quả phỏng vấn.')
SET IDENTITY_INSERT [dbo].[ApplicationStatusHistories] OFF
-- Data for [dbo].[AuditLogs]
SET IDENTITY_INSERT [dbo].[AuditLogs] ON

INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (1, 2, N'CREATE_JOB', N'Jobs', 1, N'HR tao tin tuyen dung mau cho demo.', CAST(N'2026-07-05T19:10:00.330' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (2, 3, N'UPLOAD_CV', N'CandidateFiles', 1, N'Ung vien upload CV mau cho demo.', CAST(N'2026-07-05T19:10:00.340' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (6, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Dang nhap thanh cong.', CAST(N'2026-07-06T18:54:33.407' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (7, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Dang nhap thanh cong.', CAST(N'2026-07-06T18:54:33.407' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (8, 3, N'LOGIN_FORBIDDEN', N'Users', 3, N'Tai khoan khong co quyen vao khu vuc quan tri.', CAST(N'2026-07-06T18:55:39.343' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (9, 3, N'LOGIN_FAILED', N'Users', 3, N'Dang nhap that bai.', CAST(N'2026-07-06T18:55:47.350' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (10, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Dang nhap thanh cong.', CAST(N'2026-07-07T15:34:05.167' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (11, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Dang nhap thanh cong.', CAST(N'2026-07-07T15:34:30.027' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (12, 3, N'LOGIN_FORBIDDEN', N'Users', 3, N'Tai khoan khong co quyen vao khu vuc quan tri.', CAST(N'2026-07-07T15:34:49.097' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (13, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-25T18:42:42.370' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (14, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-25T18:42:49.950' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (15, 3, N'SUBMIT_APPLICATION', N'Applications', 5, N'Ứng viên nộp hồ sơ cho tin tuyển dụng #4.', CAST(N'2026-07-25T18:42:52.447' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (16, 2, N'CREATE_INTERVIEW', N'Interviews', 2, N'Tạo lịch phỏng vấn cho hồ sơ #5.', CAST(N'2026-07-25T18:42:54.570' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (17, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-25T18:42:56.557' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (18, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-25T18:43:37.850' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (19, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-25T18:55:10.280' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (20, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-25T18:56:20.120' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (21, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-25T18:56:56.693' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (22, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-25T18:59:46.170' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (23, 3, N'SUBMIT_APPLICATION', N'Applications', 6, N'Ứng viên nộp hồ sơ cho tin tuyển dụng #2.', CAST(N'2026-07-25T19:03:41.943' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (24, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-25T19:11:35.087' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (25, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-25T20:45:13.963' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (26, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-25T21:15:33.493' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (27, 3, N'UPDATE_AVATAR', N'Users', 3, N'Ứng viên cập nhật ảnh đại diện.', CAST(N'2026-07-25T21:15:56.137' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (28, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-25T21:16:46.117' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (29, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-25T21:17:25.133' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (30, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-25T21:17:52.457' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (31, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-25T21:35:54.483' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (32, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-25T21:35:54.483' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (33, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-25T21:36:44.887' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (34, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-25T21:37:08.320' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (35, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-26T08:14:44.290' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (36, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-26T08:17:23.077' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (37, 4, N'REGISTER_CANDIDATE', N'Users', 4, N'Ứng viên tạo tài khoản.', CAST(N'2026-07-26T08:27:49.773' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (38, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T08:39:55.903' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (39, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T08:40:05.967' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (40, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T08:45:35.370' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (41, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T08:47:06.823' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (42, 4, N'LOGIN_FAILED', N'Users', 4, N'Đăng nhập thất bại.', CAST(N'2026-07-26T08:49:03.107' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (43, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T08:49:22.903' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (44, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T08:50:02.100' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (45, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T09:51:33.650' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (46, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T09:54:10.940' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (47, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T09:54:31.287' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (48, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T09:56:24.163' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (49, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T09:59:45.643' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (50, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T10:11:50.187' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (51, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T10:19:12.943' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (52, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T10:31:26.623' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (53, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T10:50:13.093' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (54, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T10:50:54.527' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (55, 1, N'UPDATE_APPLICATION_STATUS', N'Applications', 6, N'Cập nhật trạng thái từ Mới nộp sang Mời phỏng vấn.', CAST(N'2026-07-26T10:51:46.393' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (56, 1, N'UPDATE_INTERVIEW', N'Interviews', 1, N'Cập nhật lịch hoặc kết quả phỏng vấn.', CAST(N'2026-07-26T10:55:25.317' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (57, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T11:10:19.750' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (58, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T11:28:32.790' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (59, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T14:38:04.967' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (60, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T14:38:08.710' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (61, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T15:15:48.057' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (62, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T15:32:06.313' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (63, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T15:43:51.310' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (64, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T15:43:55.293' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (65, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T15:46:42.187' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (66, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T15:52:22.243' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (67, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T16:01:48.673' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (68, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T16:05:20.817' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (69, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T16:16:11.593' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (70, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T16:17:01.290' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (71, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T16:44:59.027' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (72, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T16:44:59.943' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (73, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T16:54:40.067' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (74, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:04:09.050' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (75, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:04:09.050' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (76, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:18:49.720' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (77, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:18:59.920' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (78, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:20:07.720' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (79, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:25:03.673' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (80, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:25:16.790' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (81, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:33:02.563' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (82, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:33:05.040' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (83, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:33:24.120' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (84, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:33:45.593' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (85, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:34:35.673' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (86, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:34:39.940' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (87, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:36:55.243' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (88, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:37:16.630' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (89, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:37:23.340' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (90, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:37:48.757' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (91, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:38:46.737' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (92, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:38:55.953' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (93, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:40:30.017' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (94, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:40:30.030' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (95, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:40:55.917' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (96, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:46:25.617' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (97, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:57:50.330' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (98, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T17:59:57.853' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (99, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T18:00:29.193' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (100, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T18:16:20.647' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (101, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T18:36:03.943' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (102, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T18:36:24.160' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (103, 4, N'UPDATE_AVATAR', N'Users', 4, N'Ứng viên cập nhật ảnh đại diện.', CAST(N'2026-07-26T18:37:05.393' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (104, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T18:37:11.497' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (105, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T18:38:03.580' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (106, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:05:20.573' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (107, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:05:56.900' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (108, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:08:15.880' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (109, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:14:50.153' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (110, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:18:14.983' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (111, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:27:49.760' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (112, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:35:23.840' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (113, 20, N'SUBMIT_APPLICATION', N'Applications', 7, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #6.', CAST(N'2026-07-26T15:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (114, 21, N'SUBMIT_APPLICATION', N'Applications', 8, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #7.', CAST(N'2026-07-26T11:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (115, 22, N'SUBMIT_APPLICATION', N'Applications', 9, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #8.', CAST(N'2026-07-26T07:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (116, 23, N'SUBMIT_APPLICATION', N'Applications', 10, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #9.', CAST(N'2026-07-26T03:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (117, 24, N'SUBMIT_APPLICATION', N'Applications', 11, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #10.', CAST(N'2026-07-25T23:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (118, 25, N'SUBMIT_APPLICATION', N'Applications', 12, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #11.', CAST(N'2026-07-25T19:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (119, 26, N'SUBMIT_APPLICATION', N'Applications', 13, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #12.', CAST(N'2026-07-25T15:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (120, 27, N'SUBMIT_APPLICATION', N'Applications', 14, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #13.', CAST(N'2026-07-25T11:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (121, 28, N'SUBMIT_APPLICATION', N'Applications', 15, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #14.', CAST(N'2026-07-25T07:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (122, 29, N'SUBMIT_APPLICATION', N'Applications', 16, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #15.', CAST(N'2026-07-25T03:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (123, 30, N'SUBMIT_APPLICATION', N'Applications', 17, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #16.', CAST(N'2026-07-24T23:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (124, 31, N'SUBMIT_APPLICATION', N'Applications', 18, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #17.', CAST(N'2026-07-24T19:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (125, 32, N'SUBMIT_APPLICATION', N'Applications', 19, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #18.', CAST(N'2026-07-24T15:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (126, 33, N'SUBMIT_APPLICATION', N'Applications', 20, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #19.', CAST(N'2026-07-24T11:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (127, 34, N'SUBMIT_APPLICATION', N'Applications', 21, N'Ứng viên nộp hồ sơ dữ liệu mẫu cho tin tuyển dụng #20.', CAST(N'2026-07-24T07:36:08.727' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (128, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:38:12.060' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (129, 1, N'UPDATE_APPLICATION_STATUS', N'Applications', 8, N'Cập nhật trạng thái từ Mới nộp sang Đang xem xét.', CAST(N'2026-07-26T19:40:14.100' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (130, 1, N'UPDATE_APPLICATION_STATUS', N'Applications', 13, N'Cập nhật trạng thái từ Mới nộp sang Mời phỏng vấn.', CAST(N'2026-07-26T19:40:45.013' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (131, 1, N'UPDATE_APPLICATION_STATUS', N'Applications', 2, N'Cập nhật trạng thái từ Đang xem xét sang Mời phỏng vấn.', CAST(N'2026-07-26T19:41:04.400' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (132, 1, N'CREATE_INTERVIEW', N'Interviews', 3, N'Tạo lịch phỏng vấn cho hồ sơ #15.', CAST(N'2026-07-26T19:43:15.757' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (133, 4, N'LOGIN_SUCCESS', N'Users', 4, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:43:30.797' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (134, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:45:18.923' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (135, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:56:11.113' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (136, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T19:59:00.827' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (137, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:02:33.383' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (138, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:05:35.560' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (139, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:07:48.080' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (140, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:20:42.910' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (141, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:22:07.637' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (142, 20, N'LOGIN_FAILED', N'Users', 20, N'Đăng nhập thất bại.', CAST(N'2026-07-26T20:25:04.300' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (143, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:25:09.807' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (144, 20, N'UPDATE_AVATAR', N'Users', 20, N'Ứng viên cập nhật ảnh đại diện.', CAST(N'2026-07-26T20:26:33.357' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (145, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:27:04.050' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (146, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:33:07.243' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (147, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:33:46.520' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (148, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:35:29.977' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (149, 20, N'SUBMIT_APPLICATION', N'Applications', 22, N'Ứng viên nộp hồ sơ cho tin tuyển dụng #20.', CAST(N'2026-07-26T20:36:26.557' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (150, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:36:53.893' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (151, 2, N'UPDATE_APPLICATION_STATUS', N'Applications', 22, N'Cập nhật trạng thái từ Mới nộp sang Đang xem xét.', CAST(N'2026-07-26T20:38:30.580' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (152, 2, N'UPDATE_APPLICATION_STATUS', N'Applications', 22, N'Cập nhật trạng thái từ Đang xem xét sang Mời phỏng vấn.', CAST(N'2026-07-26T20:40:04.970' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (153, 2, N'UPDATE_APPLICATION_STATUS', N'Applications', 7, N'Cập nhật trạng thái từ Mới nộp sang Đang xem xét.', CAST(N'2026-07-26T20:46:49.877' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (154, 2, N'UPDATE_APPLICATION_STATUS', N'Applications', 7, N'Cập nhật trạng thái từ Đang xem xét sang Mời phỏng vấn.', CAST(N'2026-07-26T20:47:10.683' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (155, 2, N'UPDATE_APPLICATION_STATUS', N'Applications', 7, N'Cập nhật trạng thái từ Mời phỏng vấn sang Đạt.', CAST(N'2026-07-26T20:50:47.893' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (156, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:55:57.610' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (157, 2, N'UPDATE_APPLICATION_NOTE', N'Applications', 7, N'Cập nhật ghi chú nội bộ của hồ sơ.', CAST(N'2026-07-26T20:56:22.807' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (158, 2, N'UPDATE_APPLICATION_STATUS', N'Applications', 7, N'Cập nhật trạng thái từ Đạt sang Mời phỏng vấn.', CAST(N'2026-07-26T20:57:10.453' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (159, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T20:57:17.550' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (160, 2, N'CREATE_INTERVIEW', N'Interviews', 4, N'Tạo lịch phỏng vấn cho hồ sơ #7.', CAST(N'2026-07-26T20:58:36.567' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (161, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:06:21.090' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (162, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:11:30.317' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (163, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:13:17.953' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (164, 2, N'UPDATE_INTERVIEW', N'Interviews', 4, N'Cập nhật lịch hoặc kết quả phỏng vấn.', CAST(N'2026-07-26T21:13:30.033' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (165, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:13:38.293' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (166, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:29:03.623' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (167, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:29:10.343' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (168, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:33:31.713' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (169, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:40:05.167' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (170, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-26T21:41:19.783' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (171, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T11:08:48.997' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (172, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T11:23:35.510' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (173, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T11:30:21.853' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (174, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T11:37:50.250' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (175, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T11:51:21.907' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (176, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T11:52:24.317' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (177, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T11:57:41.857' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (178, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:13:38.867' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (179, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:17:21.917' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (180, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:17:22.097' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (181, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:17:37.197' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (182, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:17:54.993' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (183, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:24:12.660' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (184, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:24:38.347' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (185, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:24:53.073' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (186, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:26:32.750' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (187, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:26:51.637' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (188, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:32:52.643' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (189, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:46:44.330' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (190, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:47:22.473' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (191, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:47:44.487' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (192, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T12:54:10.240' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (193, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-27T13:03:37.497' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (194, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-27T13:32:04.403' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (195, 20, N'SUBMIT_APPLICATION', N'Applications', 23, N'Ứng viên nộp hồ sơ cho tin tuyển dụng #33.', CAST(N'2026-07-27T13:36:46.507' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (196, 2, N'UPDATE_APPLICATION_STATUS', N'Applications', 23, N'Cập nhật trạng thái từ Mới nộp sang Đang xem xét.', CAST(N'2026-07-27T13:41:05.633' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (197, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-27T13:43:17.087' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (198, 2, N'CREATE_INTERVIEW', N'Interviews', 5, N'Tạo lịch phỏng vấn cho hồ sơ #23.', CAST(N'2026-07-27T13:45:57.620' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (199, 2, N'UPDATE_INTERVIEW', N'Interviews', 5, N'Cập nhật lịch hoặc kết quả phỏng vấn.', CAST(N'2026-07-27T13:47:47.020' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (200, 2, N'UPDATE_INTERVIEW', N'Interviews', 5, N'Cập nhật lịch hoặc kết quả phỏng vấn.', CAST(N'2026-07-27T13:49:00.280' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (201, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:15:15.153' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (202, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:15:19.270' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (203, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:20:27.817' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (204, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:25:38.627' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (205, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:25:59.887' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (206, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:28:27.447' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (207, 3, N'LOGIN_SUCCESS', N'Users', 3, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:35:16.323' AS DateTime), N'127.0.0.1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (208, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:36:19.540' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (209, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:42:40.917' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (210, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:45:51.003' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (211, 1, N'CREATE_USER', N'Users', 35, N'Tạo tài khoản hr123.', CAST(N'2026-07-27T14:50:22.710' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (212, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:50:55.157' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (213, 35, N'LOGIN_SUCCESS', N'Users', 35, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:51:23.703' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (214, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-27T14:51:48.743' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (215, 20, N'LOGIN_SUCCESS', N'Users', 20, N'Đăng nhập thành công.', CAST(N'2026-07-27T15:03:57.020' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (216, 1, N'LOGIN_SUCCESS', N'Users', 1, N'Đăng nhập thành công.', CAST(N'2026-07-27T15:05:01.690' AS DateTime), N'::1')
INSERT [dbo].[AuditLogs] ([AuditLogID], [UserID], [ActionName], [TableName], [RecordID], [Description], [CreatedAt], [IpAddress]) VALUES (217, 2, N'LOGIN_SUCCESS', N'Users', 2, N'Đăng nhập thành công.', CAST(N'2026-07-27T15:07:54.847' AS DateTime), N'::1')
SET IDENTITY_INSERT [dbo].[AuditLogs] OFF
-- Data for [dbo].[CandidateFiles]
SET IDENTITY_INSERT [dbo].[CandidateFiles] ON

INSERT [dbo].[CandidateFiles] ([CandidateFileID], [ApplicationID], [OriginalFileName], [StoredFileName], [FilePath], [FileExtension], [FileSizeKB], [UploadedAt], [UploadedByUserID], [IsDeleted]) VALUES (1, 1, N'cv-tran-van-ung-vien.pdf', N'cv-tran-van-ung-vien.pdf', N'Uploads/CVs/cv-tran-van-ung-vien.pdf', N'.pdf', 320, CAST(N'2026-07-05T19:10:00.240' AS DateTime), 3, 0)
INSERT [dbo].[CandidateFiles] ([CandidateFileID], [ApplicationID], [OriginalFileName], [StoredFileName], [FilePath], [FileExtension], [FileSizeKB], [UploadedAt], [UploadedByUserID], [IsDeleted]) VALUES (2, 2, N'cv-le-thi-minh-anh.docx', N'cv-le-thi-minh-anh.docx', N'Uploads/CVs/cv-le-thi-minh-anh.docx', N'.docx', 180, CAST(N'2026-07-05T19:10:00.257' AS DateTime), NULL, 0)
INSERT [dbo].[CandidateFiles] ([CandidateFileID], [ApplicationID], [OriginalFileName], [StoredFileName], [FilePath], [FileExtension], [FileSizeKB], [UploadedAt], [UploadedByUserID], [IsDeleted]) VALUES (3, 3, N'cv-pham-quoc-bao.pdf', N'cv-pham-quoc-bao.pdf', N'Uploads/CVs/cv-pham-quoc-bao.pdf', N'.pdf', 250, CAST(N'2026-07-05T19:10:00.270' AS DateTime), NULL, 0)
INSERT [dbo].[CandidateFiles] ([CandidateFileID], [ApplicationID], [OriginalFileName], [StoredFileName], [FilePath], [FileExtension], [FileSizeKB], [UploadedAt], [UploadedByUserID], [IsDeleted]) VALUES (6, 6, N'Hồ sơ xin việc Thiết kế Hệ thống Tím Trắng theo Phong cách Đơn sắc Hiện đại .pdf', N'c0972927fa91471089d43a7dc04cc7be.pdf', N'Uploads/CVs/c0972927fa91471089d43a7dc04cc7be.pdf', N'.pdf', 649, CAST(N'2026-07-25T19:03:41.943' AS DateTime), 3, 0)
INSERT [dbo].[CandidateFiles] ([CandidateFileID], [ApplicationID], [OriginalFileName], [StoredFileName], [FilePath], [FileExtension], [FileSizeKB], [UploadedAt], [UploadedByUserID], [IsDeleted]) VALUES (7, 22, N'Hồ sơ xin việc Thiết kế Hệ thống Tím Trắng theo Phong cách Đơn sắc Hiện đại .pdf', N'f550b2ece58d45cdb1361cfe4e13e547.pdf', N'Uploads/CVs/f550b2ece58d45cdb1361cfe4e13e547.pdf', N'.pdf', 649, CAST(N'2026-07-26T20:36:26.557' AS DateTime), 20, 0)
INSERT [dbo].[CandidateFiles] ([CandidateFileID], [ApplicationID], [OriginalFileName], [StoredFileName], [FilePath], [FileExtension], [FileSizeKB], [UploadedAt], [UploadedByUserID], [IsDeleted]) VALUES (8, 23, N'Hồ sơ xin việc Thiết kế Hệ thống Tím Trắng theo Phong cách Đơn sắc Hiện đại _2.pdf', N'b0e3550ef5c842e39785895323387be0.pdf', N'Uploads/CVs/b0e3550ef5c842e39785895323387be0.pdf', N'.pdf', 649, CAST(N'2026-07-27T13:36:46.507' AS DateTime), 20, 0)
SET IDENTITY_INSERT [dbo].[CandidateFiles] OFF
-- Data for [dbo].[Departments]
SET IDENTITY_INSERT [dbo].[Departments] ON

INSERT [dbo].[Departments] ([DepartmentID], [DepartmentName], [Description], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (1, N'Phòng Công nghệ thông tin', N'Phụ trách phát triển phần mềm và hệ thống', 1, 0, CAST(N'2026-07-05T19:10:00.007' AS DateTime), 1, CAST(N'2026-07-26T14:50:57.887' AS DateTime), 1)
INSERT [dbo].[Departments] ([DepartmentID], [DepartmentName], [Description], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (2, N'Phòng Kinh doanh', N'Phụ trách bán hàng và chăm sóc khách hàng', 1, 0, CAST(N'2026-07-05T19:10:00.010' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Departments] ([DepartmentID], [DepartmentName], [Description], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (3, N'Phòng Nhân sự', N'Phụ trách tuyển dụng và hành chính', 1, 0, CAST(N'2026-07-05T19:10:00.010' AS DateTime), 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Departments] OFF
-- Data for [dbo].[Interviews]
SET IDENTITY_INSERT [dbo].[Interviews] ON

INSERT [dbo].[Interviews] ([InterviewID], [ApplicationID], [InterviewDate], [InterviewLocation], [InterviewerUserID], [Note], [Result], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (1, 3, CAST(N'2026-07-07T19:10:00.000' AS DateTime), N'Phong hop A101', 2, N'Phong van truc tiep vong 1.', N'Chưa có kết quả', CAST(N'2026-07-05T19:10:00.303' AS DateTime), 2, CAST(N'2026-07-26T10:55:25.317' AS DateTime), 1, 0)
INSERT [dbo].[Interviews] ([InterviewID], [ApplicationID], [InterviewDate], [InterviewLocation], [InterviewerUserID], [Note], [Result], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (3, 15, CAST(N'2026-07-30T09:00:00.000' AS DateTime), N'Phong hop A101', 2, NULL, N'Chưa có kết quả', CAST(N'2026-07-26T19:43:15.757' AS DateTime), 1, NULL, NULL, 0)
INSERT [dbo].[Interviews] ([InterviewID], [ApplicationID], [InterviewDate], [InterviewLocation], [InterviewerUserID], [Note], [Result], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (4, 7, CAST(N'2026-07-29T09:00:00.000' AS DateTime), N'A09', 1, N'FFFFFRHR', N'Đạt', CAST(N'2026-07-26T20:58:36.567' AS DateTime), 2, CAST(N'2026-07-26T21:13:30.033' AS DateTime), 2, 0)
INSERT [dbo].[Interviews] ([InterviewID], [ApplicationID], [InterviewDate], [InterviewLocation], [InterviewerUserID], [Note], [Result], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID], [IsDeleted]) VALUES (5, 23, CAST(N'2026-07-28T09:00:00.000' AS DateTime), N'Phòng họp A1 hoặc đường dẫn họp thử.', NULL, N'Phỏng vấn kỹ năng kiểm thử và xử lý tình huống.', N'Không đạt', CAST(N'2026-07-27T13:45:57.620' AS DateTime), 2, CAST(N'2026-07-27T13:49:00.280' AS DateTime), 2, 0)
SET IDENTITY_INSERT [dbo].[Interviews] OFF
-- Data for [dbo].[JobPositions]
SET IDENTITY_INSERT [dbo].[JobPositions] ON

INSERT [dbo].[JobPositions] ([JobPositionID], [PositionName], [Description], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (1, N'Lập trình viên Web', N'Phát triển ứng dụng web bằng ASP.NET/C#', 1, 0, CAST(N'2026-07-05T19:10:00.027' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[JobPositions] ([JobPositionID], [PositionName], [Description], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (2, N'Chuyên viên kinh doanh', N'Tìm kiếm và chăm sóc khách hàng', 1, 0, CAST(N'2026-07-05T19:10:00.030' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[JobPositions] ([JobPositionID], [PositionName], [Description], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (3, N'Thực tập sinh nhân sự', N'Hỗ trợ công tác tuyển dụng và hồ sơ nhân sự', 1, 0, CAST(N'2026-07-05T19:10:00.030' AS DateTime), 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[JobPositions] OFF
-- Data for [dbo].[Jobs]
SET IDENTITY_INSERT [dbo].[Jobs] ON

INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (1, N'Tuyen lap trinh vien ASP.NET MVC', N'Tham gia phat trien website noi bo va cac ung dung quan ly.', N'Biet C#, ASP.NET MVC, SQL Server. Co kien thuc HTML, CSS, JavaScript.', 1, 1, N'Cong nghe thong tin', N'8 - 15 trieu', N'Cao Lanh, Dong Thap', N'Full-time', CAST(N'2026-08-04' AS Date), 1, 0, CAST(N'2026-07-05T19:10:00.103' AS DateTime), 2, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (2, N'Tuyen chuyen vien kinh doanh', N'<p></p><ol><li>Tim kiem khach hang moi, chăm sóc khách hàng hiện có và báo cáo doanh số.</li></ol>', N'<p></p><ul><li>Giao tiếp tốt, năng động, có khả năng làm việc nhóm.</li></ul>', 2, 2, N'Kinh doanh', NULL, N'Can Tho', N'Full-time', CAST(N'2026-07-30' AS Date), 1, 0, CAST(N'2026-07-05T19:10:00.120' AS DateTime), 2, CAST(N'2026-07-27T12:57:13.873' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (3, N'Tuyen thuc tap sinh nhan su', N'Ho tro dang tin, loc CV, sap xep lich phong van va luu tru ho so.', N'Sinh vien nam 3 hoac nam 4, can than, biet dung Word/Excel co ban.', 3, 3, N'Nhan su', N'Ho tro 2 - 4 trieu', N'Cao Lanh, Dong Thap', N'Internship', CAST(N'2026-07-25' AS Date), 0, 1, CAST(N'2026-07-05T19:10:00.133' AS DateTime), 2, CAST(N'2026-07-26T11:29:15.330' AS DateTime), 1)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (5, N'Tuyển lập trình viên ASP.NET MVC', N'Phát triển và bảo trì các chức năng của hệ thống tuyển dụng trên nền tảng ASP.NET MVC.
Xây dựng giao diện quản trị dành cho Admin và HR.
Làm việc với Entity Framework và SQL Server để truy vấn, cập nhật dữ liệu.
Phối hợp với các thành viên để phân tích yêu cầu và xử lý lỗi.
Kiểm thử chức năng trước khi bàn giao.
Tối ưu hiệu năng và cải thiện trải nghiệm người dùng.
Viết tài liệu mô tả các chức năng đã thực hiện.', N'Có kiến thức về C#, ASP.NET MVC, HTML, CSS và JavaScript.
Biết sử dụng SQL Server và Entity Framework.
Hiểu mô hình MVC và lập trình hướng đối tượng.
Có khả năng đọc hiểu và chỉnh sửa mã nguồn có sẵn.
Biết sử dụng Git là một lợi thế.
Có tinh thần học hỏi, chủ động và có trách nhiệm với công việc.
Chấp nhận sinh viên mới tốt nghiệp hoặc ứng viên có dưới 2 năm kinh nghiệm.
Có thể làm việc độc lập và phối hợp với nhóm.', 1, 1, N'Công nghệ thông tin', N'10–18 triệu đồng/tháng, thỏa thuận theo năng lực', N'Cao Lãnh, Đồng Tháp', N'Toàn thời gian', CAST(N'2026-08-31' AS Date), 1, 0, CAST(N'2026-07-26T14:50:11.957' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (6, N'Lập trình viên ASP.NET MVC', N'Phát triển và bảo trì các phân hệ quản trị tuyển dụng trên nền tảng ASP.NET MVC; phối hợp với nhóm kiểm thử để bảo đảm chất lượng phát hành.', N'Tối thiểu 1 năm kinh nghiệm C# và ASP.NET MVC; hiểu SQL Server, Git và mô hình MVC; tư duy giải quyết vấn đề tốt.', 1, 1, N'Công nghệ thông tin', N'14 - 20 triệu', N'Cần Thơ', N'Full-time', CAST(N'2026-09-09' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (7, N'Lập trình viên Front-end', N'Xây dựng giao diện web responsive, tối ưu trải nghiệm người dùng và phối hợp tích hợp API với nhóm back-end.', N'Nắm vững HTML, CSS, JavaScript; biết Bootstrap; có khả năng chuyển thiết kế thành giao diện chính xác và dễ truy cập.', 1, 1, N'Công nghệ thông tin', N'12 - 18 triệu', N'Cần Thơ', N'Full-time', CAST(N'2026-09-04' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (8, N'Kỹ sư phần mềm Full-stack', N'Tham gia phát triển sản phẩm nội bộ từ phân tích yêu cầu, thiết kế dữ liệu đến triển khai giao diện và nghiệp vụ máy chủ.', N'Có kinh nghiệm C#, JavaScript và SQL; hiểu REST, bảo mật ứng dụng web và quy trình review mã nguồn.', 1, 1, N'Công nghệ thông tin', N'18 - 26 triệu', N'TP. Hồ Chí Minh', N'Full-time', CAST(N'2026-09-24' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (9, N'Lập trình viên Web Junior', N'Phát triển các màn hình quản trị, sửa lỗi và viết kiểm thử dưới sự hướng dẫn của kỹ sư phụ trách.', N'Tốt nghiệp ngành liên quan; có dự án cá nhân với C# hoặc JavaScript; chủ động học hỏi và giao tiếp rõ ràng.', 1, 1, N'Công nghệ thông tin', N'9 - 13 triệu', N'Cao Lãnh, Đồng Tháp', N'Full-time', CAST(N'2026-08-30' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (10, N'Chuyên viên kiểm thử ứng dụng Web', N'Lập kế hoạch kiểm thử chức năng, ghi nhận lỗi và phối hợp cùng lập trình viên xác minh chất lượng các bản phát hành.', N'Biết thiết kế test case, kiểm thử API và truy vấn SQL cơ bản; cẩn thận, có khả năng mô tả lỗi rõ ràng.', 1, 1, N'Công nghệ thông tin', N'10 - 16 triệu', N'Cần Thơ', N'Full-time', CAST(N'2026-09-14' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (11, N'Kỹ sư DevOps ứng dụng', N'Chuẩn hóa quy trình build và triển khai ứng dụng, theo dõi môi trường vận hành và hỗ trợ xử lý sự cố phát hành.', N'Có kiến thức CI/CD, Windows Server hoặc container; hiểu Git và có khả năng viết script tự động hóa.', 1, 1, N'Công nghệ thông tin', N'17 - 25 triệu', N'Làm việc kết hợp', N'Full-time', CAST(N'2026-09-29' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (12, N'Thực tập sinh phát triển Web', N'Tham gia xây dựng tính năng nhỏ, viết tài liệu kỹ thuật và học quy trình phát triển phần mềm thực tế cùng đội dự án.', N'Sinh viên năm cuối ngành CNTT; biết nền tảng HTML, CSS, JavaScript hoặc C#; làm việc tối thiểu 4 ngày mỗi tuần.', 1, 1, N'Công nghệ thông tin', N'Hỗ trợ 4 - 6 triệu', N'Cần Thơ', N'Internship', CAST(N'2026-08-25' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (13, N'Chuyên viên kinh doanh doanh nghiệp', N'Tìm kiếm khách hàng doanh nghiệp, tư vấn giải pháp phù hợp và quản lý cơ hội bán hàng từ tiếp cận đến ký kết.', N'Tối thiểu 1 năm kinh nghiệm B2B; giao tiếp và đàm phán tốt; sử dụng được công cụ quản lý khách hàng.', 2, 2, N'Kinh doanh', N'10 - 18 triệu + thưởng', N'Cần Thơ', N'Full-time', CAST(N'2026-09-09' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (14, N'Chuyên viên phát triển thị trường', N'Nghiên cứu thị trường khu vực, xây dựng danh sách khách hàng tiềm năng và phối hợp triển khai chương trình mở rộng doanh số.', N'Có khả năng phân tích dữ liệu thị trường, lập kế hoạch và đi công tác ngắn ngày; ưu tiên kinh nghiệm ngành dịch vụ.', 2, 2, N'Kinh doanh', N'11 - 17 triệu + KPI', N'Đồng bằng sông Cửu Long', N'Full-time', CAST(N'2026-09-19' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (15, N'Nhân viên tư vấn khách hàng', N'Tiếp nhận nhu cầu, tư vấn sản phẩm, theo dõi phản hồi và duy trì trải nghiệm tích cực trong suốt quá trình sử dụng.', N'Giọng nói rõ ràng, kiên nhẫn; sử dụng tốt tin học văn phòng; có tinh thần phục vụ khách hàng.', 2, 2, N'Dịch vụ khách hàng', N'8 - 12 triệu + thưởng', N'Cao Lãnh, Đồng Tháp', N'Full-time', CAST(N'2026-09-02' AS Date), 0, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, CAST(N'2026-07-26T19:45:54.217' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (16, N'Chuyên viên chăm sóc khách hàng', N'Quản lý nhóm khách hàng hiện hữu, chủ động hỗ trợ sau bán hàng và tổng hợp các vấn đề cần cải tiến sản phẩm.', N'Có kinh nghiệm chăm sóc khách hàng; kỹ năng xử lý tình huống và viết báo cáo; làm việc nhóm tốt.', 2, 2, N'Dịch vụ khách hàng', N'9 - 14 triệu', N'Cần Thơ', N'Full-time', CAST(N'2026-09-06' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (17, N'Nhân viên kinh doanh kênh trực tuyến', N'Phát triển doanh số từ các kênh số, phản hồi khách hàng tiềm năng và theo dõi hiệu quả từng chiến dịch bán hàng.', N'Hiểu bán hàng qua mạng xã hội và nền tảng số; giao tiếp nhanh nhạy; có khả năng theo dõi chỉ số chuyển đổi.', 2, 2, N'Thương mại điện tử', N'9 - 15 triệu + hoa hồng', N'Làm việc kết hợp', N'Full-time', CAST(N'2026-09-12' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (18, N'Chuyên viên quản lý đối tác', N'Xây dựng quan hệ với đối tác phân phối, theo dõi cam kết hợp tác và phối hợp giải quyết vấn đề phát sinh.', N'Tối thiểu 2 năm kinh nghiệm kinh doanh hoặc quản lý đối tác; đàm phán tốt; sẵn sàng đi công tác.', 2, 2, N'Kinh doanh', N'14 - 22 triệu', N'TP. Hồ Chí Minh', N'Full-time', CAST(N'2026-10-04' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (19, N'Thực tập sinh kinh doanh', N'Hỗ trợ tìm kiếm khách hàng, cập nhật dữ liệu bán hàng và chuẩn bị tài liệu tư vấn dưới sự hướng dẫn của chuyên viên.', N'Sinh viên khối kinh tế; giao tiếp tự tin; sử dụng Excel cơ bản; làm việc tối thiểu 3 tháng.', 2, 2, N'Kinh doanh', N'Hỗ trợ 3 - 5 triệu', N'Cần Thơ', N'Internship', CAST(N'2026-08-27' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (20, N'Thực tập sinh tuyển dụng', N'Hỗ trợ đăng tin, sàng lọc hồ sơ, liên hệ ứng viên và chuẩn bị lịch phỏng vấn cho các vị trí đang tuyển.', N'Sinh viên ngành nhân sự hoặc kinh tế; giao tiếp lịch sự; cẩn thận với dữ liệu ứng viên; sử dụng tốt Word và Excel.', 3, 3, N'Nhân sự', N'Hỗ trợ 3 - 5 triệu', N'Cần Thơ', N'Internship', CAST(N'2026-08-25' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (21, N'Thực tập sinh truyền thông nội bộ', N'Hỗ trợ xây dựng nội dung bản tin, tổ chức hoạt động gắn kết và ghi nhận phản hồi của nhân viên.', N'Có khả năng viết nội dung và thiết kế cơ bản; năng động, tổ chức công việc tốt; ưu tiên có sản phẩm mẫu.', 3, 3, N'Nhân sự', N'Hỗ trợ 3 - 5 triệu', N'Cần Thơ', N'Internship', CAST(N'2026-08-31' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (22, N'Thực tập sinh đào tạo nhân sự', N'Hỗ trợ chuẩn bị tài liệu, quản lý danh sách học viên và tổng hợp đánh giá sau các chương trình đào tạo nội bộ.', N'Sinh viên ngành quản trị nhân lực; kỹ năng Excel và trình bày tốt; chủ động theo dõi tiến độ.', 3, 3, N'Nhân sự', N'Hỗ trợ 3 - 5 triệu', N'Cao Lãnh, Đồng Tháp', N'Internship', CAST(N'2026-09-08' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (23, N'Cộng tác viên tuyển dụng', N'Tìm kiếm nguồn ứng viên, đăng nội dung tuyển dụng và hỗ trợ xác nhận lịch phỏng vấn theo nhu cầu từng đợt.', N'Có thể làm việc từ xa; giao tiếp rõ ràng; cam kết bảo mật thông tin ứng viên và hoàn thành chỉ tiêu đúng hạn.', 3, 3, N'Nhân sự', N'Theo hiệu quả công việc', N'Làm việc từ xa', N'Part-time', CAST(N'2026-09-14' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (24, N'Thực tập sinh C&B', N'Hỗ trợ kiểm tra dữ liệu chấm công, sắp xếp hồ sơ nhân sự và chuẩn bị báo cáo phục vụ công tác lương thưởng.', N'Cẩn thận với số liệu; sử dụng Excel khá; hiểu nguyên tắc bảo mật dữ liệu nhân sự.', 3, 3, N'Nhân sự', N'Hỗ trợ 3 - 5 triệu', N'Cần Thơ', N'Internship', CAST(N'2026-09-22' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (25, N'Thực tập sinh hành chính nhân sự', N'Hỗ trợ quản lý văn phòng phẩm, hồ sơ nhân viên, công văn và các hoạt động hành chính hằng ngày.', N'Sinh viên năm cuối; tác phong chuyên nghiệp; sắp xếp công việc tốt; có thể làm việc giờ hành chính.', 3, 3, N'Hành chính nhân sự', N'Hỗ trợ 3 - 5 triệu', N'Cần Thơ', N'Internship', CAST(N'2026-09-04' AS Date), 1, 0, CAST(N'2026-07-26T19:17:37.810' AS DateTime), 1, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (26, N'QA TEST - Nhân viên kiểm thử phần mềm', N'<p>Thực hiện kiểm thử chức năng website ATS v&#224; ghi nhận lỗi.</p>', N'<p>C&#243; kiến thức kiểm thử phần mềm v&#224; kỹ năng l&#224;m việc nh&#243;m.</p>', 2, 1, N'Marketing', N'12.000.000 - 18.000.000 VNĐ', N'TP. Hồ Chí Minh', N'Toàn thời gian', CAST(N'2026-12-31' AS Date), 1, 0, CAST(N'2026-07-27T11:41:12.147' AS DateTime), 2, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (27, N'QA TEST - Nhân viên kiểm thử phần mềmrre', N'<ul><li>Có kiến thức kiểm thử phần mềm và kỹ năng làm việc nhóm.</li></ul>', N'<div><ol><li><b>Thực hiện kiểm thử chức năng website ATS và ghi nhận lỗi</b>.</li></ol></div>', 2, 2, N'Thiết kế', N'12.000.000 - 18.000.000 VNĐ', N'TP. Hồ Chí Minh', N'Bán thời gian', CAST(N'2026-12-31' AS Date), 1, 0, CAST(N'2026-07-27T11:59:26.807' AS DateTime), 2, NULL, NULL)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (28, N'QA TEST - Nhân viên kiểm thử phần mềm123', N'<ol><li>ddđ</li></ol>', N'<ul><li>grgrgr</li></ul>', 1, 2, N'Thiết kế', N'12.000.000 - 18.000.000 VNĐ', N'TP. Hồ Chí Minh', N'Bán thời gian', CAST(N'2026-11-12' AS Date), 0, 1, CAST(N'2026-07-27T12:03:30.487' AS DateTime), 2, CAST(N'2026-07-27T12:06:25.113' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (29, N'vdvdvd123', N'&lt;iframe src="javascript:alert(''iframe-xss'')"&gt;&lt;/iframe&gt;<div>&lt;img src="x" onerror="alert(''image-xss'')"&gt;</div><div>&lt;svg onload="alert(''svg-xss'')"&gt;&lt;/svg&gt;</div><div>&lt;p onclick="alert(''click-xss'')"&gt;Nội dung công việc hợp lệ&lt;/p&gt;</div>', N'<p>gg</p>', 1, 2, N'Tài chính - Kế toán', N'12.000.000 - 18.000.000 VNĐ', N'TP. Hồ Chí Minh', N'Toàn thời gian', CAST(N'2026-12-12' AS Date), 1, 0, CAST(N'2026-07-27T12:07:31.073' AS DateTime), 2, CAST(N'2026-07-27T12:10:49.263' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (30, N'DDDDD', N'<p>dd</p>', N'<p>dd</p>', 1, 2, N'Thiết kế', N'12.000.000 - 18.000.000 VNĐ', N'TP. Hồ Chí Minh', N'Toàn thời gian', CAST(N'2026-12-12' AS Date), 1, 0, CAST(N'2026-07-27T12:15:14.383' AS DateTime), 2, CAST(N'2026-07-27T12:20:00.457' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (31, N'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', N'<p>CĐ</p>', N'<p>DD</p>', 1, 2, N'Vận hành', N'12.000.000 - 18.000.000 VNĐ', N'TP. Hồ Chí Minh', N'Toàn thời gian', CAST(N'2026-12-12' AS Date), 0, 1, CAST(N'2026-07-27T12:20:40.310' AS DateTime), 2, CAST(N'2026-07-27T12:57:35.933' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (32, N'11122ccđ#', N'<p>dfef</p>', N'<p>êfe</p>', 1, 2, N'Thiết kế', N'12.000.000 - 18.000.000 VNĐ', N'TP. Hồ Chí Minh', N'Bán thời gian', CAST(N'2026-07-27' AS Date), 0, 1, CAST(N'2026-07-27T12:28:51.597' AS DateTime), 2, CAST(N'2026-07-27T12:29:06.003' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (33, N'Kỹ sư Kiểm thử (QA/QC) – Web & Mobile', N'<p>VỀ VỊ TRÍ CÔNG VIỆC</p><p>Chúng tôi đang tìm kiếm một Chuyên viên Quan hệ Đối tác (Dịch vụ Di động) năng động và có khả năng phân tích cao để thúc đẩy lập kế hoạch chiến lược, thực hiện chiến dịch và tối ưu hóa hiệu suất cho các dịch vụ di động trong Zalopay, bao gồm các đối tác chiến lược về gọi xe và các sáng kiến ​​sản phẩm di động trong ứng dụng nhằm đạt được các mục tiêu tăng trưởng người dùng đầy tham vọng.</p><p>Vị trí này hoạt động ở giao điểm của công nghệ tài chính, di động và tiếp thị người tiêu dùng, chuyển đổi những hiểu biết từ hệ sinh thái của Zalopay , xu hướng thị trường và hành vi người dùng thành các chiến lược khả thi và các chiến dịch có tác động cao. Bạn sẽ hợp tác chặt chẽ với các nhóm chức năng khác nhau (Sản phẩm, Tăng trưởng, Dữ liệu, Đối tác, Vận hành) và các đối tác di động bên ngoài để định hình cách người dùng di chuyển và thanh toán hàng ngày.</p><p>Bạn sẽ là ứng viên lý tưởng nếu bạn hiểu rõ các yếu tố thúc đẩy kinh doanh trong lĩnh vực di động và cơ chế tăng trưởng của ngành công nghệ tài chính (Fintech).</p><p>TRÁCH NHIỆM CHÍNH</p><p>1. Quản lý các bên liên quan và đối tác (60%)</p><p>Đóng vai trò là người liên lạc giữa bộ phận tiếp thị, sản phẩm và các đối tác bên ngoài để đảm bảo sự phù hợp về chiến lược và việc giao hàng đúng thời hạn .</p><p>Hỗ trợ các quan hệ đối tác chiến lược và các sáng kiến ​​tiếp thị chung bằng cách điều phối các nguồn lực chiến dịch và theo dõi kết quả.</p><p>Xác định và phát triển các mối quan hệ đối tác chiến lược để mở rộng phạm vi hệ sinh thái, đẩy nhanh quá trình thu hút người dùng và khai phá các cơ hội tăng trưởng thị trường mới.&nbsp;</p><p>2. Quản lý và thực thi dự án (20%)</p><p>Chịu trách nhiệm lập kế hoạch, phối hợp và thực hiện các chiến dịch marketing tích hợp, đảm bảo phù hợp với mục tiêu kinh doanh và chiến lược của nhà cung cấp.</p><p>Phối hợp với nhóm Growth MKT để xác định mục tiêu chiến dịch , đối tượng mục tiêu, ngân sách, thời gian thực hiện và các chỉ số KPI thành công.</p><p>Phối hợp chặt chẽ với nhóm Growth MKT để giám sát việc lập kế hoạch sáng tạo, lên kế hoạch truyền thông và luồng thông tin trên các kênh.</p><p>Theo dõi hiệu quả chiến dịch, giám sát các chỉ số KPI và đưa ra các đề xuất tối ưu hóa dựa trên dữ liệu.</p><p>3. Hiệu suất &amp; Báo cáo (20%)</p><p>Tổng hợp các báo cáo chiến dịch, theo dõi hiệu suất so với KPI và tạo ra các đánh giá sau chiến dịch để rút ra bài học kinh nghiệm và thực tiễn tốt nhất.</p><p>Phối hợp chặt chẽ với nhóm Dữ liệu để đánh giá hiệu quả đầu tư chiến dịch (ROI) và xác định các cơ hội cải tiến liên tục.</p>', N'<p></p><ul><li>Bằng cử nhân Quản trị kinh doanh , Kinh tế, Truyền thông hoặc các ngành liên quan.&nbsp;</li><li>Ít nhất 2 năm kinh nghiệm trong quản lý khách hàng, lập kế hoạch kinh doanh, chiến lược tiếp thị hoặc quản lý chiến dịch (kinh nghiệm trong lĩnh vực công nghệ, fintech, gọi xe, thương mại điện tử là một lợi thế).</li><li>Khả năng giao tiếp và thuyết trình xuất sắc, tự tin làm việc với các bên liên quan cấp cao.&nbsp;</li><li>Kỹ năng phân tích và giải quyết vấn đề xuất sắc; khả năng chuyển đổi dữ liệu thành những thông tin hữu ích có thể áp dụng ngay.</li><li>Kỹ năng quản lý dự án và tổ chức xuất sắc, chú trọng đến từng chi tiết.</li><li>Thành thạo Excel/Google Sheets, PowerPoint/Slides và quen thuộc với các công cụ phân tích dữ liệu hoặc BI.</li></ul>', 1, 2, N'Thiết kế', N'12.000.000 - 18.000.000 VNĐ', N'Tầng 5, Tòa nhà A&B – Quận 1, TP. Hồ Chí Minh', N'Bán thời gian', CAST(N'2026-07-27' AS Date), 1, 0, CAST(N'2026-07-27T12:31:20.363' AS DateTime), 2, CAST(N'2026-07-27T13:30:22.207' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (34, N'scsc123', N'<p>ee33t@#</p>', N'<p>##@Ffdf</p>', 1, 2, N'Thiết kế', NULL, N'Tầng 5, Tòa nhà A&B – Quận 1, TP. Hồ Chí Minh', N'Bán thời gian', CAST(N'2026-12-12' AS Date), 1, 0, CAST(N'2026-07-27T12:59:21.820' AS DateTime), 2, CAST(N'2026-07-27T12:59:59.823' AS DateTime), 2)
INSERT [dbo].[Jobs] ([JobID], [Title], [Description], [Requirements], [DepartmentID], [JobPositionID], [Industry], [SalaryRange], [Location], [JobType], [Deadline], [IsActive], [IsDeleted], [CreatedAt], [CreatedByUserID], [UpdatedAt], [UpdatedByUserID]) VALUES (35, N'QA TEST - Nhân viên kiểm thử phần mềm 2026', N'<ul><li>Thực hiện kiểm thử chức năng hệ thống ATS, ghi nhận lỗi và phối hợp với nhóm phát triển.</li></ul>', N'<h3><ol><li>Có kiến thức kiểm thử phần mềm, viết test case và báo cáo lỗi. Chấp nhận sinh viên mới tốt nghiệp.</li></ol></h3>', 1, 2, N'Marketing', N'12.000.000 - 18.000.000 VNĐ', N'Tầng 5, Tòa nhà A&B – Quận 1, TP. Hồ Chí Minh', N'Toàn thời gian', CAST(N'2026-12-12' AS Date), 1, 0, CAST(N'2026-07-27T13:01:52.537' AS DateTime), 2, CAST(N'2026-07-27T13:51:58.237' AS DateTime), 2)
SET IDENTITY_INSERT [dbo].[Jobs] OFF
-- Data for [dbo].[Notifications]
SET IDENTITY_INSERT [dbo].[Notifications] ON

INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (1, 1, 7, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Nguyễn Minh Anh vừa ứng tuyển Lập trình viên ASP.NET MVC.', CAST(N'2026-07-26T15:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (2, 1, 8, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Trần Quốc Bảo vừa ứng tuyển Lập trình viên Front-end.', CAST(N'2026-07-26T11:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (3, 1, 9, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Lê Hoàng Duy vừa ứng tuyển Kỹ sư phần mềm Full-stack.', CAST(N'2026-07-26T07:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (4, 1, 10, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Phạm Thu Hà vừa ứng tuyển Lập trình viên Web Junior.', CAST(N'2026-07-26T03:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (5, 1, 11, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Võ Gia Hân vừa ứng tuyển Chuyên viên kiểm thử ứng dụng Web.', CAST(N'2026-07-25T23:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (6, 1, 12, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Đặng Tuấn Kiệt vừa ứng tuyển Kỹ sư DevOps ứng dụng.', CAST(N'2026-07-25T19:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (7, 1, 13, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Bùi Ngọc Lan vừa ứng tuyển Thực tập sinh phát triển Web.', CAST(N'2026-07-25T15:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (8, 1, 14, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Nguyễn Đức Long vừa ứng tuyển Chuyên viên kinh doanh doanh nghiệp.', CAST(N'2026-07-25T11:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (9, 1, 15, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Trần Khánh Linh vừa ứng tuyển Chuyên viên phát triển thị trường.', CAST(N'2026-07-25T07:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (10, 1, 16, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Lê Nhật Minh vừa ứng tuyển Nhân viên tư vấn khách hàng.', CAST(N'2026-07-25T03:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (11, 1, 17, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Phạm Quỳnh Như vừa ứng tuyển Chuyên viên chăm sóc khách hàng.', CAST(N'2026-07-24T23:36:08.790' AS DateTime), CAST(N'2026-07-26T19:38:30.323' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (12, 1, 18, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Võ Thành Phát vừa ứng tuyển Nhân viên kinh doanh kênh trực tuyến.', CAST(N'2026-07-24T19:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (13, 1, 19, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Đặng Yến Nhi vừa ứng tuyển Chuyên viên quản lý đối tác.', CAST(N'2026-07-24T15:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (14, 1, 20, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Bùi Anh Thư vừa ứng tuyển Thực tập sinh kinh doanh.', CAST(N'2026-07-24T11:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (15, 1, 21, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Nguyễn Hải Yến vừa ứng tuyển Thực tập sinh tuyển dụng.', CAST(N'2026-07-24T07:36:08.790' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (16, 1, 22, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Nguyễn Minh Anh vừa ứng tuyển Thực tập sinh tuyển dụng.', CAST(N'2026-07-26T20:36:26.853' AS DateTime), CAST(N'2026-07-27T13:43:27.437' AS DateTime))
INSERT [dbo].[Notifications] ([NotificationID], [RecipientUserID], [ApplicationID], [NotificationType], [Title], [Message], [CreatedAt], [ReadAt]) VALUES (17, 2, 23, N'NEW_APPLICATION', N'Hồ sơ ứng tuyển mới', N'Hd vừa ứng tuyển Kỹ sư Kiểm thử (QA/QC) – Web & Mobile.', CAST(N'2026-07-27T13:36:46.740' AS DateTime), CAST(N'2026-07-27T13:37:50.663' AS DateTime))
SET IDENTITY_INSERT [dbo].[Notifications] OFF
-- Data for [dbo].[Roles]
SET IDENTITY_INSERT [dbo].[Roles] ON

INSERT [dbo].[Roles] ([RoleID], [RoleName], [Description], [IsActive]) VALUES (1, N'Admin', N'Quan tri he thong', 1)
INSERT [dbo].[Roles] ([RoleID], [RoleName], [Description], [IsActive]) VALUES (2, N'HR', N'Nhan su tuyen dung', 1)
INSERT [dbo].[Roles] ([RoleID], [RoleName], [Description], [IsActive]) VALUES (3, N'Candidate', N'Ung vien', 1)
SET IDENTITY_INSERT [dbo].[Roles] OFF
-- Data for [dbo].[SavedJobs]
SET IDENTITY_INSERT [dbo].[SavedJobs] ON

INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (15, 20, 2, CAST(N'2026-07-27T14:38:48.720' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (16, 20, 1, CAST(N'2026-07-27T14:38:49.457' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (17, 20, 20, CAST(N'2026-07-27T14:38:50.303' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (18, 20, 12, CAST(N'2026-07-27T14:38:51.107' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (19, 20, 19, CAST(N'2026-07-27T14:38:51.920' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (20, 20, 9, CAST(N'2026-07-27T14:38:52.707' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (21, 20, 21, CAST(N'2026-07-27T14:38:53.447' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (22, 20, 5, CAST(N'2026-07-27T14:38:54.150' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (23, 20, 16, CAST(N'2026-07-27T14:38:56.507' AS DateTime))
INSERT [dbo].[SavedJobs] ([SavedJobID], [CandidateUserID], [JobID], [SavedAt]) VALUES (24, 20, 25, CAST(N'2026-07-27T14:38:57.187' AS DateTime))
SET IDENTITY_INSERT [dbo].[SavedJobs] OFF
-- Data for [dbo].[Users]
SET IDENTITY_INSERT [dbo].[Users] ON

INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (1, N'admin', N'PBKDF2-SHA256$100000$F/tGeAHRvDT+Qu5bca9BRouAP1TrRvzrhRashM39wkw=', N'kuI9nvtWg5NiqDQTGX0io7QF+hJXjY2on1zEwDqn0Ic=', N'Quan tri vien', N'admin@ats.local', N'0900000001', 1, 0, NULL, CAST(N'2026-07-27T15:05:01.690' AS DateTime), 1, CAST(N'2026-07-05T19:09:59.980' AS DateTime), CAST(N'2026-07-27T15:05:01.690' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (2, N'hr01', N'PBKDF2-SHA256$100000$aYV+AHVHmJUv8t5DlmuCD+eaWuqf72oDpmxZxD2tgfE=', N'AKF6//LiZM1i1IGPtJoDPvuRWkK4igiyjaDq3W6+1UI=', N'Nguyen Thi HR', N'hr01@ats.local', N'0900000002', 2, 0, NULL, CAST(N'2026-07-27T15:07:54.847' AS DateTime), 1, CAST(N'2026-07-05T19:09:59.987' AS DateTime), CAST(N'2026-07-27T15:07:54.847' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (3, N'ungvien01', N'PBKDF2-SHA256$100000$+tjL8xg1rNsQtDarLBRWt1BzwXWdtCZBTAaXOgHBlS8=', N'vCU3JPL20SXZOXwiTcl04GxLXqKWTRmkowaN9zL3E0Y=', N'Tran Van Ung Vien', N'ungvien01@example.com', N'0900000003', 3, 0, NULL, CAST(N'2026-07-27T14:35:16.323' AS DateTime), 1, CAST(N'2026-07-05T19:09:59.987' AS DateTime), CAST(N'2026-07-27T14:35:16.323' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (4, N'candidate_test_260726_01', N'PBKDF2-SHA256$100000$R/TID6PSZLrBjzPty7PMeor65M0WbpGWw9oPRqbCkLE=', N'fIFpLauXjs8VsfyOjtiqWTly/d0hjIVOPv3f+u0tpII=', N'Nguyễn Văn Test', N'candidate.test.26072601@example.com', N'0901234567', 3, 0, NULL, CAST(N'2026-07-26T19:43:30.797' AS DateTime), 1, CAST(N'2026-07-26T08:27:49.410' AS DateTime), CAST(N'2026-07-26T19:43:30.797' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (20, N'ungvien02', N'PBKDF2-SHA256$100000$PSWPsNjJxfoREOreBOXvKTbvKPH5kMYXJ+JDHRQ+7cM=', N'm+S4GB3KIiZ7TNTl8G6hkvJYyIgdYAM4JQYx5Ll8py4=', N'Nguyễn Minh Anh', N'ungvien02@example.com', N'0911000002', 3, 0, NULL, CAST(N'2026-07-27T15:03:57.017' AS DateTime), 1, CAST(N'2026-07-26T19:35:08.627' AS DateTime), CAST(N'2026-07-27T15:03:57.017' AS DateTime))
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (21, N'ungvien03', N'D9080974D9E46174F07AE17FCE941D816C3E08799C425A4A6D337EA62DDD7464', N'ATS_DEMO_CANDIDATE03', N'Trần Quốc Bảo', N'ungvien03@example.com', N'0911000003', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:34:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (22, N'ungvien04', N'552B85470E851BA22D2F91176F1734106DD6A3710A431806F648FF0E1F32DC71', N'ATS_DEMO_CANDIDATE04', N'Lê Hoàng Duy', N'ungvien04@example.com', N'0911000004', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:33:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (23, N'ungvien05', N'0185443C82CAAD7AB28232977BB7BC0EF024DFA0B3A0A72B9F485802813544E0', N'ATS_DEMO_CANDIDATE05', N'Phạm Thu Hà', N'ungvien05@example.com', N'0911000005', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:32:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (24, N'ungvien06', N'1BE1B6BBB914EADDA64F1EA7F156A4405FC22ED1BFE2B50EDC8CC84C79592304', N'ATS_DEMO_CANDIDATE06', N'Võ Gia Hân', N'ungvien06@example.com', N'0911000006', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:31:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (25, N'ungvien07', N'41A3B138E98DF067C7EE2EA2DE7387DC08A84B63528662043AB578A7D2DC925F', N'ATS_DEMO_CANDIDATE07', N'Đặng Tuấn Kiệt', N'ungvien07@example.com', N'0911000007', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:30:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (26, N'ungvien08', N'2C285A8DCFA2D7CCC8A40208D140FA92298EBD40E1435E922863D1C6BA13394B', N'ATS_DEMO_CANDIDATE08', N'Bùi Ngọc Lan', N'ungvien08@example.com', N'0911000008', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:29:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (27, N'ungvien09', N'7F9157AFE64C29D0299E311327CB5FA925322BF02C687E88DC117883D63BF8C1', N'ATS_DEMO_CANDIDATE09', N'Nguyễn Đức Long', N'ungvien09@example.com', N'0911000009', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:28:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (28, N'ungvien10', N'6EE0E9B59E60955FFEB0F0EFE6BEC9E0CA97052F38863CFD536A01E59E7D4B11', N'ATS_DEMO_CANDIDATE10', N'Trần Khánh Linh', N'ungvien10@example.com', N'0911000010', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:27:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (29, N'ungvien11', N'5755F9E007C2FDA09BC748FA3A62786C3A15F14909627A37009B993C407EA6FC', N'ATS_DEMO_CANDIDATE11', N'Lê Nhật Minh', N'ungvien11@example.com', N'0911000011', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:26:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (30, N'ungvien12', N'CC5C7975D0CB0520FFE86E03B1E107BAC7C7F7D4A7769A5ACE88CC7048488235', N'ATS_DEMO_CANDIDATE12', N'Phạm Quỳnh Như', N'ungvien12@example.com', N'0911000012', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:25:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (31, N'ungvien13', N'22AD48380A540B48E05C51B08E35E91A34DCAF4009B5460FA2C6C9847C4C948F', N'ATS_DEMO_CANDIDATE13', N'Võ Thành Phát', N'ungvien13@example.com', N'0911000013', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:24:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (32, N'ungvien14', N'20678019F7FB97A8B77705A989CB17CCA4BFA9796458A9745C89FF0ED8AE923E', N'ATS_DEMO_CANDIDATE14', N'Đặng Yến Nhi', N'ungvien14@example.com', N'0911000014', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:23:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (33, N'ungvien15', N'8CE392C92D7B0608712E8F81033CD9472D1E201EBE6B4683829FFBB9914C5967', N'ATS_DEMO_CANDIDATE15', N'Bùi Anh Thư', N'ungvien15@example.com', N'0911000015', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:22:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (34, N'ungvien16', N'D7FC0DB0769EC78980E3627E05748D8C67865DDA6FBCBAAD8168D541E33EB511', N'ATS_DEMO_CANDIDATE16', N'Nguyễn Hải Yến', N'ungvien16@example.com', N'0911000016', 3, 0, NULL, NULL, 1, CAST(N'2026-07-26T19:21:08.627' AS DateTime), NULL)
INSERT [dbo].[Users] ([UserID], [Username], [PasswordHash], [PasswordSalt], [FullName], [Email], [Phone], [RoleID], [FailedLoginCount], [LockedUntil], [LastLoginAt], [IsActive], [CreatedAt], [UpdatedAt]) VALUES (35, N'hr123', N'PBKDF2-SHA256$100000$XxUSxvbRjatUFDDzfRtm6VXTpIVaqtjz8gwEwx5uXWU=', N'+7L3HBr1FQkWFrp/YvxoxWRpbnNp/qkYVAZTcyh17Xc=', N'Nhân sự Demo', N'hr.demo@ats.local', N'0900000048', 2, 0, NULL, CAST(N'2026-07-27T14:51:23.703' AS DateTime), 1, CAST(N'2026-07-27T14:50:22.677' AS DateTime), CAST(N'2026-07-27T14:51:23.703' AS DateTime))
SET IDENTITY_INSERT [dbo].[Users] OFF
-- Validate and enable all constraints after importing data.
ALTER TABLE [dbo].[Applications] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[ApplicationStatuses] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[ApplicationStatusHistories] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[AuditLogs] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[CandidateFiles] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Departments] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Interviews] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[JobPositions] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Jobs] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Notifications] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Roles] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[SavedJobs] WITH CHECK CHECK CONSTRAINT ALL
GO
ALTER TABLE [dbo].[Users] WITH CHECK CHECK CONSTRAINT ALL
GO
PRINT N'Imported database [ATSMiniDB_StudentPlus] successfully.'
GO
