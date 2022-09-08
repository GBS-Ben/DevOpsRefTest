CREATE TABLE [dbo].[ReportData_DailyApparelOrders]
(
[RunDate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderDate] [datetime] NULL,
[OPID] [int] NOT NULL,
[productQuantity] [int] NULL,
[productName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApparelType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Color] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Size] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]