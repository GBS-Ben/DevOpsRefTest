CREATE TABLE [dbo].[ReportMarkfulShopsUYO]
(
[orderID] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[companyName] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GBSCompanyID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShopSetupOrder] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]