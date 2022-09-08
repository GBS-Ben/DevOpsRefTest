CREATE TABLE [dbo].[tblINV_PO_Notes]
(
[noteID] [int] NOT NULL IDENTITY(1, 1),
[poID] [int] NULL,
[itemID] [int] NULL,
[notes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[noteDate] [datetime] NULL,
[author] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblINV_PO_Notes] ADD CONSTRAINT [PK_tblINV_PO_Notes] PRIMARY KEY CLUSTERED  ([noteID]) WITH (FILLFACTOR=90) ON [PRIMARY]