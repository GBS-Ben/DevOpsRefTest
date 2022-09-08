CREATE TABLE [dbo].[Report_KPIDate31]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[DateKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Metric01_Num_ActiveShops_1MT] [int] NULL,
[Metric02_Num_OrdersThroughShops_1MT] [int] NULL,
[Metric22_Num_OrdersNotThroughShops_1MT] [int] NULL,
[Metric03_Perc_OrdersThroughShops_1MT] [money] NULL,
[Metric04_Rev_ThroughShops_1MT] [int] NULL,
[Metric05_Rev_NotThroughShops_1MT] [int] NULL,
[Metric06_Perc_TotalRevThroughShops_1MT] [money] NULL,
[Metric07_Num_CustomersUsingShops_1MT] [int] NULL,
[Metric08_Num_CustomersNotUsingShops_1MT] [int] NULL,
[Metric09_Perc_CustomersUsingShops_1MT] [money] NULL,
[Metric10_Avg_ShopValue_1MT] [int] NULL
) ON [PRIMARY]