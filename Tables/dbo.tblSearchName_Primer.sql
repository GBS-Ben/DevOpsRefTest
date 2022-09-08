CREATE TABLE [dbo].[tblSearchName_Primer]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [iX_orderNo] ON [dbo].[tblSearchName_Primer] ([orderNo]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [iX_PKID] ON [dbo].[tblSearchName_Primer] ([RowID]) ON [PRIMARY]