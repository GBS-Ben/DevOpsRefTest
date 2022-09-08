CREATE TABLE [dbo].[tblOrdersInvoice]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invoiceNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invoiceDate] [datetime2] NOT NULL CONSTRAINT [DF__tblOrderI__invoi__65DBE6B6] DEFAULT (getdate()),
[invoiceTotal] [decimal] (8, 2) NOT NULL,
[invoiceFile] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]