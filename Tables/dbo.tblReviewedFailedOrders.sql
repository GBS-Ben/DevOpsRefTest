CREATE TABLE [dbo].[tblReviewedFailedOrders]
(
[customerID] [int] NOT NULL,
[orderID] [int] NULL,
[firstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suburb] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[orderTotal] [money] NULL,
[orderStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]