CREATE TABLE [dbo].[Report_KPIDate91]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[DateKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Metric01_Num_ActiveShops_3MT] [int] NULL,
[Metric02_Num_OrdersThroughShops_3MT] [int] NULL,
[Metric22_Num_OrdersNotThroughShops_3MT] [int] NULL,
[Metric03_Perc_OrdersThroughShops_3MT] [money] NULL,
[Metric04_Rev_ThroughShops_3MT] [int] NULL,
[Metric05_Rev_NotThroughShops_3MT] [int] NULL,
[Metric06_Perc_TotalRevThroughShops_3MT] [money] NULL,
[Metric07_Num_CustomersUsingShops_3MT] [int] NULL,
[Metric08_Num_CustomersNotUsingShops_3MT] [int] NULL,
[Metric09_Perc_CustomersUsingShops_3MT] [money] NULL,
[Metric10_Avg_ShopValue_3MT] [int] NULL
) ON [PRIMARY]