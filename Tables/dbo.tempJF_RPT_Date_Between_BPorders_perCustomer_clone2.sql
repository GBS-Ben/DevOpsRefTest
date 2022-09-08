CREATE TABLE [dbo].[tempJF_RPT_Date_Between_BPorders_perCustomer_clone2]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[daysTranspired] [int] NULL,
[firstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]