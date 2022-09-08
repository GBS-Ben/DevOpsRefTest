CREATE TABLE [dbo].[impoLog]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[opid] [int] NULL,
[impoName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[impoType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[impoStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logTimeStamp] [datetime] NOT NULL CONSTRAINT [DF_ImpoLog_logTimeStamp] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_JF] ON [dbo].[impoLog] ([opid], [impoName]) ON [PRIMARY]