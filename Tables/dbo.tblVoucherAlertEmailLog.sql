CREATE TABLE [dbo].[tblVoucherAlertEmailLog]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[DateEmailSent] [datetime2] NULL,
[VoucherCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HTMLBody] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientEmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNo] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVoucherAlertEmailLog] ADD CONSTRAINT [PK_tblVoucherAlertEmailLog] PRIMARY KEY CLUSTERED  ([LogId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblVoucherAlertEmailLog_OrderNo] ON [dbo].[tblVoucherAlertEmailLog] ([OrderNo]) ON [PRIMARY]