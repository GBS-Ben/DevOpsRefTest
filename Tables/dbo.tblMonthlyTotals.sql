CREATE TABLE [dbo].[tblMonthlyTotals]
(
[OrderDate] [varchar] (767) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderTotal] [money] NULL,
[orderQuantity] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]