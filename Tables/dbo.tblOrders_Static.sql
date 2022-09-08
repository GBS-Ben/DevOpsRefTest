CREATE TABLE [dbo].[tblOrders_Static]
(
[orderID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderAck] [bit] NULL,
[orderForPrint] [bit] NULL,
[orderJustPrinted] [bit] NULL,
[orderBatchedDate] [datetime] NULL,
[orderPrintedDate] [datetime] NULL,
[orderCancelled] [bit] NULL CONSTRAINT [DF_tblOrders_Static_orderCancelled] DEFAULT ((0)),
[customerID] [int] NULL,
[membershipID] [int] NULL,
[membershipType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sessionID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[orderTotal] [money] NULL,
[taxAmountInTotal] [money] NULL,
[taxAmountAdded] [money] NULL,
[taxDescription] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shippingAmount] [money] NULL,
[shippingMethod] [int] NULL,
[shippingDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipDate] [datetime] NULL,
[feeAmount] [money] NULL,
[paymentAmountRequired] [money] NULL,
[paymentMethod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentMethodID] [int] NULL,
[paymentMethodRDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentMethodIsCC] [bit] NULL,
[paymentMethodIsSC] [bit] NULL,
[cardNumber] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardExpiryMonth] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardExpiryYear] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardCCV] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardStoreInfo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Surname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_PostCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billingAddressID] [int] NULL,
[billing_FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Surname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Street2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_PostCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blindShip] [bit] NULL,
[specialInstructions] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentProcessed] [bit] NULL,
[paymentProcessedDate] [datetime] NULL,
[paymentSuccessful] [bit] NULL,
[cartVersion] [int] NULL,
[ipAddress] [nvarchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referrer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[archived] [bit] NULL,
[messageToCustomer] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reasonforpurchase] [varchar] (355) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusTemp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusDate] [datetime] NULL,
[orderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrders_Static_orderType] DEFAULT ('Stock'),
[emailStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrders_Static_emailStatus] DEFAULT ((1)),
[actMigStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tabStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tblOrders_Static_tabStatus] DEFAULT ('new'),
[importFlag] [int] NULL CONSTRAINT [DF_tblOrders_Static_importFlag] DEFAULT ((0)),
[specialOffer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[storeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrders_Static_storeID] DEFAULT ('HOM'),
[coordIDUsed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brokerOwnerIDUsed] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[importDate] [datetime] NULL,
[invRefDate] [datetime] NULL,
[repName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowUpdate] [timestamp] NULL,
[grpOrder] [bit] NULL CONSTRAINT [DF_tblOrders_Static_grpOrder] DEFAULT ((0)),
[lastStatusUpdate] [datetime] NULL,
[promoName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sampler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrders_Static_sampler] DEFAULT ('no'),
[shipZone] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResCom] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderWeight] [float] NULL,
[com] [float] NULL,
[res] [float] NULL,
[aReg] [float] NULL,
[bReg] [float] NULL,
[stockShipFirst] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calcOrderTotal] [money] NULL,
[calcTransTotal] [money] NULL,
[calcProducts] [money] NULL,
[calcOPPO] [money] NULL,
[calcVouchers] [money] NULL,
[calcCredits] [money] NULL,
[displayPaymentStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_on] [datetime] NULL CONSTRAINT [DF_tblOrders_Static_lastUpdate] DEFAULT (getdate()),
[modified_on] [datetime] NULL CONSTRAINT [DF__tblOrders__modif__208265DC] DEFAULT (getdate()),
[billingReference] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOrders_Static] ADD CONSTRAINT [PK_tblOrders_Static] PRIMARY KEY CLUSTERED  ([orderID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrderNO] ON [dbo].[tblOrders_Static] ([orderNo]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'reasonforpurchase'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'shipping_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'shipping_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'shipping_FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'shipping_Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'shipping_PostCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'shipping_State'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'shipping_Street'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders_Static', 'COLUMN', N'shipping_Suburb'