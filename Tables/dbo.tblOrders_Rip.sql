CREATE TABLE [dbo].[tblOrders_Rip]
(
[orderID] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderAck] [bit] NOT NULL,
[orderCancelled] [bit] NULL,
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
[shippingDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[feeAmount] [money] NULL,
[paymentAmountRequired] [money] NULL,
[paymentMethod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentMethodID] [int] NULL,
[paymentMethodRDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentMethodIsCC] [bit] NOT NULL,
[paymentMethodIsSC] [bit] NOT NULL,
[cardNumber] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardExpiryMonth] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardExpiryYear] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardCCV] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardStoreInfo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shippingAddressID] [int] NULL,
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
[specialInstructions] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentProcessed] [bit] NOT NULL,
[paymentProcessedDate] [datetime] NULL,
[paymentSuccessful] [bit] NOT NULL,
[ipAddress] [nvarchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referrer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[archived] [bit] NOT NULL,
[messageToCustomer] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coordIDUsed] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brokerOwnerIDUsed] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOrderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[repName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[promoName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sampler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billingAddressID] [int] NULL,
[cartVersion] [int] NULL,
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
[billingReference] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]