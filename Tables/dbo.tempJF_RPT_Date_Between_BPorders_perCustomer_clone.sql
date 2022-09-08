CREATE TABLE [dbo].[tempJF_RPT_Date_Between_BPorders_perCustomer_clone]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[orderDate] [datetime] NULL,
[daysTranspired] [int] NULL
) ON [PRIMARY]