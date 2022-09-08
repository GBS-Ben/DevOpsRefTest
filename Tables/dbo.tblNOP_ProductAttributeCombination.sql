CREATE TABLE [dbo].[tblNOP_ProductAttributeCombination]
(
[Id] [int] NOT NULL,
[ProductId] [int] NOT NULL,
[AttributesXml] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StockQuantity] [int] NOT NULL,
[AllowOutOfStockOrders] [bit] NOT NULL,
[Sku] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ManufacturerPartNumber] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gtin] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OverriddenPrice] [numeric] (18, 4) NULL,
[NotifyAdminForQuantityBelow] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblNOP_ProductAttributeCombination] ADD CONSTRAINT [PK_tblNOP_ProductAttributeCombination] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]