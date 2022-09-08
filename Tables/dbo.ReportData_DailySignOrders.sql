CREATE TABLE [dbo].[ReportData_DailySignOrders]
(
[RunDate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderDate] [datetime] NULL,
[OPID] [int] NOT NULL,
[productQuantity] [int] NULL,
[Width] [varchar] (56) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Height] [varchar] (58) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaterialType] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]