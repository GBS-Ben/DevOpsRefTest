CREATE TABLE [dbo].[BC_LOG]
(
[lognote] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logdate] [datetime] NULL CONSTRAINT [DF_BC_LOG_logdate] DEFAULT (getdate())
) ON [PRIMARY]