CREATE TABLE [dbo].[tblNBQTY]
(
[ID] [int] NOT NULL IDENTITY(900000, 1),
[productCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productQuantity] [int] NULL,
[orderID] [int] NULL
) ON [PRIMARY]