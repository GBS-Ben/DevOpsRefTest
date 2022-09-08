CREATE TABLE [dbo].[tempJF_tblProof]
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
[deleted] [int] NOT NULL,
[importFlag] [bit] NOT NULL
) ON [PRIMARY]