CREATE TABLE [dbo].[ReportShopsPMI]
(
[Todays_Date] [datetime] NULL,
[Day_of_Week] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[New_Shops_Launched] [int] NULL,
[Old_Shops_Activated] [int] NULL,
[Total_NonActive_Shops] [int] NULL,
[Total_Active_Shops] [int] NULL,
[AVG_NumDays_Launch2Order_3MT] [int] NULL,
[AVG_Shop_Value_12MT] [int] NULL
) ON [PRIMARY]