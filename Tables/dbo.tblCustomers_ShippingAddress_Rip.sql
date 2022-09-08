CREATE TABLE [dbo].[tblCustomers_ShippingAddress_Rip]
(
[customerID] [int] NULL,
[ShippingAddressID_Remote] [int] NULL,
[Shipping_Company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Surname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Street2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_PostCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Phone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_FullName] [nvarchar] (101) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary_Address] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[address_Type] [bit] NOT NULL CONSTRAINT [DF_tblCustomers_ShippingAddress_Rip_address_Type] DEFAULT ((1))
) ON [PRIMARY]