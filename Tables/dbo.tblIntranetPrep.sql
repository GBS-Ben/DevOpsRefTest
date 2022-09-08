CREATE TABLE [dbo].[tblIntranetPrep]
(
[orderID] [int] NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[orderTotal] [money] NULL,
[paymentProcessed] [bit] NULL,
[customerID] [int] NULL,
[shippingDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[surname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pickup date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduled delivery date] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]