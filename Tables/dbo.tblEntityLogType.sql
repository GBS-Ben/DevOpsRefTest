CREATE TABLE [dbo].[tblEntityLogType]
(
[LogTypeId] [int] NOT NULL IDENTITY(1, 1),
[LogType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEntityLogType] ADD CONSTRAINT [PK_tblEntityLogType] PRIMARY KEY CLUSTERED ([LogTypeId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LogType] ON [dbo].[tblEntityLogType] ([LogType]) ON [PRIMARY]