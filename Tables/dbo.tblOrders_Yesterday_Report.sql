CREATE TABLE [dbo].[tblOrders_Yesterday_Report]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[firstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumDistinctProducts] [int] NULL,
[subTotal] [money] NULL,
[Tax] [money] NULL,
[ShippingTotal] [money] NULL,
[OrderTotal] [money] NULL,
[reasonForPurchase] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referrer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]