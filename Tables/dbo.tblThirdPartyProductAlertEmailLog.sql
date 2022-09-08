CREATE TABLE [dbo].[tblThirdPartyProductAlertEmailLog]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[DateEmailSent] [datetime2] NULL,
[HTMLBody] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientEmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNo] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblThirdPartyProductAlertEmailLog] ADD CONSTRAINT [PK_tblThirdPartyProductAlertEmailLog] PRIMARY KEY CLUSTERED  ([LogId]) ON [PRIMARY]