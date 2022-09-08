CREATE TABLE [dbo].[ReportMarkfulShopsUYO_forOutput]
(
[customerid] [int] NULL,
[customername] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numOrders] [int] NULL,
[sumTotal] [money] NULL,
[latestOrderDate] [datetime] NULL,
[latestOrderID] [int] NULL,
[latestOrderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]