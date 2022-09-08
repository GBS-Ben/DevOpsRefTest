CREATE TABLE [dbo].[tblStore_ShippingOrderTotals]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[shippingID] [int] NULL,
[orderTotalLower] [real] NULL,
[orderTotalUpper] [real] NULL,
[amount] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_ShippingOrderTotals] ADD CONSTRAINT [PK_tblStore_ShippingOrderTotals] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]