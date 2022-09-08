CREATE TABLE [dbo].[Report_KPIDate]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[DateKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Metric01_Num_ActiveShops_12MT] [int] NULL,
[Metric02_Num_OrdersThroughShops_12MT] [int] NULL,
[Metric22_Num_OrdersNotThroughShops_12MT] [int] NULL,
[Metric03_Perc_OrdersThroughShops_12MT] [money] NULL,
[Metric04_Rev_ThroughShops_12MT] [int] NULL,
[Metric05_Rev_NotThroughShops_12MT] [int] NULL,
[Metric06_Perc_TotalRevThroughShops_12MT] [money] NULL,
[Metric07_Num_CustomersUsingShops_12MT] [int] NULL,
[Metric08_Num_CustomersNotUsingShops_12MT] [int] NULL,
[Metric09_Perc_CustomersUsingShops_12MT] [money] NULL,
[Metric10_Avg_ShopValue_12MT] [int] NULL
) ON [PRIMARY]