CREATE TABLE [dbo].[tbl_Notes]
(
[PKID] [int] NOT NULL IDENTITY(1343, 1),
[orderID] [int] NULL,
[jobNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[noteDate] [datetime] NULL,
[author] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proofNote_ref_PKID] [int] NULL,
[notesType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deleteX] [bit] NULL CONSTRAINT [DF_tblnote_deleteX] DEFAULT ((0)),
[systemNote] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordersProductsID] [int] NULL CONSTRAINT [DF_tblnote_ordersProductsID] DEFAULT ((0)),
[switch_NoteType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_Notes] ADD CONSTRAINT [PK_tblnote] PRIMARY KEY CLUSTERED ([PKID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_author_notesType_INC_PKID] ON [dbo].[tbl_Notes] ([author], [notesType]) INCLUDE ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_jobNumber_INC_notes_noteDate] ON [dbo].[tbl_Notes] ([jobNumber]) INCLUDE ([notes], [noteDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_jobNumber_notesType] ON [dbo].[tbl_Notes] ([jobNumber], [notesType]) INCLUDE ([orderID], [notes], [noteDate], [author], [proofNote_ref_PKID], [deleteX], [systemNote], [ordersProductsID], [switch_NoteType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_noteDate_inc_jobNumber_notes] ON [dbo].[tbl_Notes] ([noteDate]) INCLUDE ([jobNumber], [notes]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tbl_Notes_notesType_ordersProductsID] ON [dbo].[tbl_Notes] ([notesType], [ordersProductsID]) INCLUDE ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PNR] ON [dbo].[tbl_Notes] ([proofNote_ref_PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblNOTES_SystemNoteJobNumber] ON [dbo].[tbl_Notes] ([systemNote], [jobNumber]) ON [PRIMARY]