CREATE TABLE [dbo].[tbl_NotesArchive]
(
[PKID] [int] NOT NULL IDENTITY(1343, 1),
[orderID] [int] NULL,
[jobNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[noteDate] [datetime] NULL,
[author] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proofNote_ref_PKID] [int] NULL,
[notesType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deleteX] [bit] NULL,
[systemNote] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordersProductsID] [int] NULL,
[switch_NoteType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_NotesArchive] ADD CONSTRAINT [PK_tbl_NotesArchive] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_JN] ON [dbo].[tbl_NotesArchive] ([jobNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OID] ON [dbo].[tbl_NotesArchive] ([orderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_systemNote] ON [dbo].[tbl_NotesArchive] ([systemNote]) INCLUDE ([PKID]) ON [PRIMARY]