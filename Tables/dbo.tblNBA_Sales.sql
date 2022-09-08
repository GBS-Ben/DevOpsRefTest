CREATE TABLE [dbo].[tblNBA_Sales]
(
[team] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalSales] [money] NULL,
[totalCartons] [int] NULL
) ON [PRIMARY]