CREATE TABLE [dbo].[tblCustomers_BillingAddress]
(
[BillingAddressID] [int] NOT NULL IDENTITY(46600, 1),
[CustomerID] [int] NULL,
[Billing_NickName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_FirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Surname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Street] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Street2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Suburb] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_PostCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_Phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing_FullName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameOnCard] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardExpMonth] [int] NULL,
[CardExpYear] [int] NULL,
[CardCCV] [int] NULL,
[Primary_Address] [bit] NOT NULL CONSTRAINT [DF_tblCustomers_BillingAddress_Primary_Address] DEFAULT ((0)),
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deletex] [bit] NOT NULL CONSTRAINT [DF_tblCustomers_BillingAddress_deletex] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCustomers_BillingAddress] ADD CONSTRAINT [PK_tblCustomers_BillingAddress] PRIMARY KEY CLUSTERED  ([BillingAddressID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_BillingAddress_Billing_Phone] ON [dbo].[tblCustomers_BillingAddress] ([Billing_Phone]) INCLUDE ([BillingAddressID], [CustomerID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_BillingAddress_CustomerID_Billing_Phone] ON [dbo].[tblCustomers_BillingAddress] ([CustomerID], [Billing_Phone]) INCLUDE ([BillingAddressID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCustomers_BillingAddress_orderNo] ON [dbo].[tblCustomers_BillingAddress] ([orderNo]) ON [PRIMARY]