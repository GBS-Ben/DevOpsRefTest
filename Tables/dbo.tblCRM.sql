CREATE TABLE [dbo].[tblCRM]
(
[orderID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderAck] [bit] NULL,
[orderForPrint] [bit] NULL,
[orderJustPrinted] [bit] NULL,
[orderBatchedDate] [datetime] NULL,
[orderPrintedDate] [datetime] NULL,
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
[shippingDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[feeAmount] [money] NULL,
[paymentAmountRequired] [money] NULL,
[paymentMethod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentMethodID] [int] NULL,
[paymentMethodRDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
[shipping_FirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Surname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_PostCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Mobile] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[specialInstructions] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentProcessed] [bit] NULL,
[paymentProcessedDate] [datetime] NULL,
[paymentSuccessful] [bit] NULL,
[ipAddress] [nvarchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referrer] [nvarchar] (355) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[archived] [bit] NULL,
[messageToCustomer] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reasonforpurchase] [varchar] (355) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusTemp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusDate] [datetime] NULL,
[orderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[actMigStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tabStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[importFlag] [int] NULL,
[specialOffer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[storeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[coordIDUsed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brokerOwnerIDUsed] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[seasonYear] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAT_Football] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAT_Baseball] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAT_Calendars] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAT_Pad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAT_Stock] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAT_Envelopes] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAT_DoorknobBags] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAT_AdhesiveMags] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STYLE_Custom] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STYLE_QuickCard] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STYLE_QuickStix] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suggested_ProFootball] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suggested_CollegeFootball] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suggested_Baseball] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suggested_Hockey] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suggested_Basketball] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRM_callStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRM_emailStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRM_followup] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRM_inactive] [bit] NOT NULL,
[CRM_groupID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRM_InfoBlockAvailable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updateDate] [datetime] NULL,
[fanFlag] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[proFootballFan] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[collegeFootballFan] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[baseballFan] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hockeyFan] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[basketballFan] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[survey_State_052908] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[survey_Respondant_052908] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[survey_Used_Football_Mags_In_The_Past_052908] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[survey_Which_Magnet_Style_052908] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[survey_Add_5_Cents_052908] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[survey_InfoBlock] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[differential] [datetime] NULL,
[birthday] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jobTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numAgents] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[salesContact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_contact_date] [datetime] NULL,
[dataSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[salesCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nonOrder] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailSent] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpTotalSales] [smallmoney] NULL,
[grpTotalOrders] [int] NULL,
[grpMaster] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderYear] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpnotes] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grplastOrderDate] [datetime] NULL,
[grpOfficeNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpOfficePhone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpOfficeName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpOfficeRegionalName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpOfficeStreet] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpOfficeCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpOfficeState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grpOfficeZip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[regionNo] [int] NULL,
[regionName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[regionJobTitle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[importREFID] [int] NULL,
[numLocations] [int] NULL,
[import_Sort] [int] NULL
) ON [PRIMARY]