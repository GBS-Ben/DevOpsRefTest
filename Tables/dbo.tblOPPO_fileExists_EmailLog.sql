CREATE TABLE [dbo].[tblOPPO_fileExists_EmailLog]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[rowID] [int] NOT NULL,
[OPID] [int] NOT NULL,
[emailSent] [bit] NOT NULL CONSTRAINT [DF_tblOPPO_fileExists_EmailLog_emailSent] DEFAULT ((0)),
[emailSentTo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailSentOn] [datetime] NOT NULL CONSTRAINT [DF_tblOPPO_fileExists_EmailLog_emailSentOn] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_email_INC_emailSent] ON [dbo].[tblOPPO_fileExists_EmailLog] ([OPID]) INCLUDE ([emailSent]) ON [PRIMARY]