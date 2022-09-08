CREATE TABLE [dbo].[tblSearchName_Constructed]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchName] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_FirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_SurName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_FirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_SurName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblCustomers_firstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblCustomers_surName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblCustomers_ShippingAddress_Shipping_FirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblCustomers_ShippingAddress_Shipping_SurName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [iX_uC_orderNo] ON [dbo].[tblSearchName_Constructed] ([orderNo]) ON [PRIMARY]