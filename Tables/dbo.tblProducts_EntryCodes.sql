CREATE TABLE [dbo].[tblProducts_EntryCodes]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[orderDetailID] [int] NULL,
[entryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_PKID] ON [dbo].[tblProducts_EntryCodes] ([pkid]) ON [PRIMARY]