CREATE TABLE [dbo].[StatusLog]
(
[StatusLogID] [int] NOT NULL IDENTITY(1, 1),
[StatusType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDValue] [int] NULL,
[NewStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StatusUpdateDate] [datetime] NOT NULL CONSTRAINT [DF_StatusLog_StatusUpdateDate] DEFAULT (getdate())
) ON [PRIMARY]