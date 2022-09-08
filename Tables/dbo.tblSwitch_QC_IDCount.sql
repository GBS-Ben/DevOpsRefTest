CREATE TABLE [dbo].[tblSwitch_QC_IDCount]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[orderID] [int] NULL,
[ordersProductsID] [int] NULL,
[numDistinctProductsPerOrder] [int] NULL
) ON [PRIMARY]