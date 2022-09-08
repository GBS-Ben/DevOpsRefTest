CREATE TABLE [dbo].[tblStore_Email]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[emailCustomerReceipt] [bit] NOT NULL,
[receiptSubject] [nvarchar] (165) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[receiptFormat] [int] NULL,
[receiptEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmSubject] [nvarchar] (165) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[confirmEmailPartial] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requestConfirmTrackingNo] [bit] NOT NULL,
[ccStaff] [bit] NOT NULL,
[staffEmail1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[staffEmail2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[staffEmail3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailFromAddress] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[voucherSubject] [nvarchar] (165) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[voucherBody] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailSystem] [int] NULL,
[emailSystemServer] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_Email] ADD CONSTRAINT [PK_tblStore_Email] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]