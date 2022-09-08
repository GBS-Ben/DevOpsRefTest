﻿CREATE TABLE [dbo].[TEMPJFtblSwitch_CACX]
(
[orderID] [int] NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[customerID] [int] NULL,
[shippingAddressID] [int] NULL,
[shipCompany] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipFirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipLastName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipAddress1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipAddress2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipCity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipState] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipZip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipCountry] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipPhone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shortName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productQuantity] [int] NULL,
[packetValue] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[variableTopName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[variableBottomName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[variableWholeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numUnits] [int] NULL,
[displayedQuantity] [int] NULL,
[ordersProductsID] [int] NULL,
[shipsWith] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[resubmit] [bit] NULL,
[shipType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[samplerRequest] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[multiCount] [int] NULL,
[totalCount] [int] NULL,
[displayCount] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[background] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[templateFile] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team1FileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team2FileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team3FileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team4FileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team5FileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team6FileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[groupID] [int] NULL,
[productID] [int] NULL,
[parentProductID] [int] NULL,
[switch_create] [bit] NULL,
[switch_createDate] [datetime] NULL,
[switch_approve] [bit] NULL,
[switch_approveDate] [datetime] NULL,
[switch_print] [bit] NULL,
[switch_printDate] [datetime] NULL,
[switch_import] [bit] NULL,
[mo_orders_Products] [datetime] NULL,
[mo_orders] [datetime] NULL,
[mo_customers] [datetime] NULL,
[mo_customers_ShippingAddress] [datetime] NULL,
[mo_oppo] [datetime] NULL,
[customProductCount] [int] NULL,
[customProductCode1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customProductCode2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customProductCode3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customProductCode4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fasTrakProductCount] [int] NULL,
[fasTrakProductCode1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fasTrakProductCode2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fasTrakProductCode3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fasTrakProductCode4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductCount] [int] NULL,
[stockProductQuantity1] [int] NULL,
[stockProductCode1] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductDescription1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductQuantity2] [int] NULL,
[stockProductCode2] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductDescription2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductQuantity3] [int] NULL,
[stockProductCode3] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductDescription3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductQuantity4] [int] NULL,
[stockProductCode4] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductDescription4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductQuantity5] [int] NULL,
[stockProductCode5] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductDescription5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductQuantity6] [int] NULL,
[stockProductCode6] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockProductDescription6] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UV] [int] NOT NULL,
[customBackground] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]