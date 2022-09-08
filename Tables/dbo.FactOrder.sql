CREATE TABLE [dbo].[FactOrder]
(
[StoreKey] [int] NULL,
[CustomerKey] [int] NULL,
[OrderDateKey] [int] NULL,
[ShipDateKey] [int] NULL,
[PaymentDateKey] [int] NULL,
[OrderTimeKey] [int] NULL,
[ShipTimeKey] [int] NULL,
[PaymentTimeKey] [int] NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShippingAmount] [money] NULL,
[CalcOrderTotal] [money] NULL,
[CalcTransTotal] [money] NULL,
[CalcProducts] [money] NULL,
[CalcOPPO] [money] NULL,
[calcVouchers] [money] NULL,
[calcCredits] [money] NULL,
[orderDate] [datetime] NULL,
[shipDate] [datetime] NULL,
[PaymentProcessedDate] [datetime] NULL
) ON [PRIMARY]