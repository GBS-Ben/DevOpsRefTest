CREATE TABLE [dbo].[tempJF_fb21]
(
[email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastOrderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastOrderDate] [datetime] NULL,
[sum_FootballOrderTotals] [money] NULL,
[sum_AllOrderTotals] [money] NULL,
[customerName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[companyName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]