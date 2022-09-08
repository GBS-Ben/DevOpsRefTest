CREATE TABLE [dbo].[tblProof]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proofResponse] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proofVersion] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proofNotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proofSignature] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseDate] [datetime] NULL,
[ordersProductsID] [int] NULL,
[uploadedFile] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deleted] [int] NOT NULL CONSTRAINT [DF_tblProof_deleted] DEFAULT ((0)),
[importFlag] [bit] NOT NULL CONSTRAINT [DF_tblProof_importFlag] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProof] ADD CONSTRAINT [PK_tblProof] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_importFlag] ON [dbo].[tblProof] ([importFlag]) ON [PRIMARY]