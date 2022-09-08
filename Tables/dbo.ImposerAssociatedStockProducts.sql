CREATE TABLE [dbo].[ImposerAssociatedStockProducts]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[OrderID] [int] NULL,
[AssociatedOPID] [int] NULL,
[AssociatedProductQuantity] [int] NULL,
[AssociatedProductPriceQuantity] [int] NULL,
[AssociatedProductName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssociatedProductCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]