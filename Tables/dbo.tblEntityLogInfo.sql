CREATE TABLE [dbo].[tblEntityLogInfo]
(
[LogId] [bigint] NOT NULL,
[LogInfo] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEntityLogInfo] ADD CONSTRAINT [FK_tblEntityLogInfo_tblEntityLog] FOREIGN KEY ([LogId]) REFERENCES [dbo].[tblEntityLog] ([LogId])