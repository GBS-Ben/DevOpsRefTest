CREATE TABLE [dbo].[tblEntityStatus]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[EntityId] [int] NOT NULL,
[EntityName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusDate] [datetime] NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_tblStatusTracker_createdDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tblStatusTracker_createdBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEntityStatus] ADD CONSTRAINT [PK_tblStatusTracker] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]