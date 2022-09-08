CREATE TABLE [dbo].[tblSetupAlertEmailLog]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[DateEmailSent] [datetime2] NULL,
[HTMLBody] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientEmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNo] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Opid] [int] NULL,
[AlertType] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSetupAlertEmailLog] ADD CONSTRAINT [PK_tblSetupAlertEmailLog] PRIMARY KEY CLUSTERED  ([LogId]) ON [PRIMARY]