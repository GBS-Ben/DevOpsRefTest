CREATE TABLE [dbo].[tblOrderInvoice]
(
[PKID] [int] NOT NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invoiceNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invoiceDate] [datetime2] NOT NULL,
[invoiceTotal] [decimal] (8, 2) NOT NULL,
[invoiceFile] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]