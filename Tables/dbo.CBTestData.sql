CREATE TABLE [dbo].[CBTestData]
(
[OrderNo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OrdersProductsId] [int] NULL,
[Key] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createdOn] [datetime2] NULL
) ON [PRIMARY]