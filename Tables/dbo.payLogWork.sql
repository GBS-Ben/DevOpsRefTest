CREATE TABLE [dbo].[payLogWork]
(
[orderID] [int] NULL,
[orderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentGoodDate] [datetime] NULL,
[onHOMDockDate] [datetime] NULL,
[numDays] [int] NULL
) ON [PRIMARY]