CREATE TABLE [dbo].[tblOrderView]
(
[orderID] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNumeric] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastStatusUpdate] [datetime] NULL,
[orderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[orderTotal] [money] NULL,
[paymentProcessed] [bit] NULL,
[coordIDUsed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brokerOwnerIDUsed] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[specialOffer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerID] [int] NULL,
[shippingDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shippingMethod] [int] NULL,
[shipDate] [datetime] NULL,
[storeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[archived] [bit] NULL,
[firstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[surname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Company] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_FirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Surname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Suburb] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_PostCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Company] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_FirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Surname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Street] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Street2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Suburb] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_PostCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tabStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderAck] [bit] NULL,
[paymentSuccessful] [bit] NULL,
[paymentAmountRequired] [money] NULL,
[paymentMethod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusDate] [datetime] NULL,
[searchName] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchCompany] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchAddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchState] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchZip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchPhone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_on] [datetime] NULL,
[tblOrders_shipping_Company] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_FirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_Surname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_Street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_Street2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_Suburb] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_PostCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_shipping_Phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_Company] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_FirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_Surname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_Street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_Street2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_Suburb] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_PostCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_Country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_billing_Phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cartVersion] [int] NULL,
[billingReference] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOP] [bit] NOT NULL CONSTRAINT [DF_tblOrderView_NOP] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOrderView] ADD CONSTRAINT [PK_tblOrderView] PRIMARY KEY NONCLUSTERED  ([orderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_email] ON [dbo].[tblOrderView] ([email]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderDate] ON [dbo].[tblOrderView] ([orderDate]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_ORDERID] ON [dbo].[tblOrderView] ([orderID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblOrderView] ([orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderStatus] ON [dbo].[tblOrderView] ([orderStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrderView_OrderStatusOrderDate] ON [dbo].[tblOrderView] ([orderStatus], [orderDate]) INCLUDE ([orderID], [orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderTotal] ON [dbo].[tblOrderView] ([orderTotal]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderType] ON [dbo].[tblOrderView] ([orderType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tabStatus] ON [dbo].[tblOrderView] ([tabStatus]) ON [PRIMARY]