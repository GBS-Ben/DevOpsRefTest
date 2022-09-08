CREATE TABLE [dbo].[tblOrders_GenericFees]
(
[orderID] [int] NULL,
[feeName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OID] ON [dbo].[tblOrders_GenericFees] ([orderID]) ON [PRIMARY]