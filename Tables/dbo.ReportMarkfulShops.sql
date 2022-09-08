CREATE TABLE [dbo].[ReportMarkfulShops]
(
[orderID] [int] NOT NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[companyName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GBSCompanyID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShopSetUpOrder] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]