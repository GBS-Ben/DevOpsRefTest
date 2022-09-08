CREATE TABLE [dbo].[tblOPIDStatusLog]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[OPID] [int] NOT NULL,
[prev_fastTrak_status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_fastTrak_status] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusChangeDate] [datetime] NULL CONSTRAINT [DF_tblOPIDStatusLog_statusChangeDate] DEFAULT (getdate())
) ON [PRIMARY]