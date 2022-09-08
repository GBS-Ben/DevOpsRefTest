CREATE TABLE [dbo].[tblOPPO_email]
(
[rowID] [int] NOT NULL IDENTITY(1, 1),
[orderID] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPID] [int] NOT NULL,
[PKID] [int] NOT NULL,
[textValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleanFront] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleanFront2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleanBack] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cleanBack2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dirty] [bit] NOT NULL CONSTRAINT [DF_tblOPPO_Email_wasCleaned] DEFAULT ((0)),
[clean] [bit] NOT NULL CONSTRAINT [DF_tblOPPO_email_clean] DEFAULT ((0)),
[junk] [bit] NOT NULL CONSTRAINT [DF_tblOPPO_email_junk] DEFAULT ((0)),
[insertDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOPPO_email] ADD CONSTRAINT [PK_tblOPPO_Email] PRIMARY KEY CLUSTERED  ([rowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_cleanJunk_rowIDcleanBack] ON [dbo].[tblOPPO_email] ([clean], [junk]) INCLUDE ([rowID], [cleanBack]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_CleanJunk_INC_rowIDcleanBack2] ON [dbo].[tblOPPO_email] ([clean], [junk]) INCLUDE ([rowID], [cleanBack2]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_cleanJunk_inc_rowIDcleanFront] ON [dbo].[tblOPPO_email] ([clean], [junk]) INCLUDE ([rowID], [cleanFront]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_cleanJunk_INC_rowIDemailDirty] ON [dbo].[tblOPPO_email] ([clean], [junk]) INCLUDE ([rowID], [email], [dirty]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_dirty_INC_rowIDtextValue] ON [dbo].[tblOPPO_email] ([dirty]) INCLUDE ([rowID], [textValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_OPID] ON [dbo].[tblOPPO_email] ([OPID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderID] ON [dbo].[tblOPPO_email] ([orderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderNo] ON [dbo].[tblOPPO_email] ([orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_PKID] ON [dbo].[tblOPPO_email] ([PKID]) ON [PRIMARY]