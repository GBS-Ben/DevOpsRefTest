CREATE TABLE [dbo].[tblEntityLog]
(
[LogId] [bigint] NOT NULL IDENTITY(1, 1),
[EntityId] [int] NOT NULL,
[EntityTypeID] [int] NOT NULL,
[LogTypeID] [int] NOT NULL,
[LogDateTime] [datetime] NOT NULL,
[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_tblEntityLog_createdDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tblEntityLog_createdBy] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEntityLog] ADD CONSTRAINT [FK_tblEntityLog_tblEntityLogType] FOREIGN KEY ([LogTypeID]) REFERENCES [dbo].[tblEntityLogType] ([LogTypeId])
GO
ALTER TABLE [dbo].[tblEntityLog] ADD CONSTRAINT [FK_tblEntityLog_tblEntityType] FOREIGN KEY ([EntityTypeID]) REFERENCES [dbo].[tblEntityType] ([EntityTypeId])
GO
ALTER TABLE [dbo].[tblEntityLog] ADD CONSTRAINT [PK_tblEntityLog] PRIMARY KEY CLUSTERED ([LogId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EntityID] ON [dbo].[tblEntityLog] ([EntityId]) INCLUDE ([EntityTypeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LogTypeID] ON [dbo].[tblEntityLog] ([LogTypeID]) ON [PRIMARY]