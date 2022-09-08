CREATE TABLE [dbo].[tblCustomers_Billing]
(
[customerID] [int] NOT NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_FirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Street] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Suburb] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_PostCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]