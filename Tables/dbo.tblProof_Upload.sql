CREATE TABLE [dbo].[tblProof_Upload]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[ordersProductsID] [int] NOT NULL,
[uploadedFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProof_Upload] ADD CONSTRAINT [PK_tblProof_Upload] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]