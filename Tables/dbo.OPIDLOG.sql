CREATE TABLE [dbo].[OPIDLOG]
(
[PKID] [int] NOT NULL IDENTITY(10000, 1),
[OPID] [int] NULL,
[LogEvent] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogTimeStamp] [datetime] NULL CONSTRAINT [DF_Table_1_LogDate] DEFAULT (getdate())
) ON [PRIMARY]