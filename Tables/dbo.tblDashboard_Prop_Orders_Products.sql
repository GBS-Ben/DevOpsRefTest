CREATE TABLE [dbo].[tblDashboard_Prop_Orders_Products]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[orderID] [int] NULL,
[productID] [int] NULL,
[productCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productPrice] [money] NULL,
[productQuantity] [int] NULL,
[ordersProductsID] [int] NULL,
[modDiff] [bit] NULL CONSTRAINT [tblDashboard_Prop_Orders_Products_modDiff] DEFAULT ((0)),
[tblOrders_Products_modified_on] [datetime] NULL,
[deleteX] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[readyForProp] [int] NULL CONSTRAINT [DF_tblDashboard_Prop_Orders_Products_readyForProp] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDashboard_Prop_Orders_Products] ADD CONSTRAINT [PK_tblDashboard_Prop_Orders_Products] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblDashboard_Prop_Orders_Products_modDiff] ON [dbo].[tblDashboard_Prop_Orders_Products] ([modDiff]) INCLUDE ([PKID], [ordersProductsID], [tblOrders_Products_modified_on]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_modDiff_readyForProp] ON [dbo].[tblDashboard_Prop_Orders_Products] ([modDiff], [readyForProp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OPID01] ON [dbo].[tblDashboard_Prop_Orders_Products] ([ordersProductsID]) ON [PRIMARY]