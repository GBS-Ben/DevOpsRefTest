CREATE TABLE [dbo].[tblCheck]
(
[CheckID] [int] NOT NULL IDENTITY(1, 1),
[OrderID] [int] NULL,
[EntryDate] [datetime] NULL,
[Method] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckAmount] [money] NULL,
[DeleteRecord] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCheck] ADD CONSTRAINT [PK_tblCheck] PRIMARY KEY CLUSTERED  ([CheckID]) WITH (FILLFACTOR=90) ON [PRIMARY]