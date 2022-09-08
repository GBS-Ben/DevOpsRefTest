CREATE TABLE [dbo].[tblCustomers_ShippingAddressBOUNCE]
(
[ShippingAddressID] [int] NOT NULL IDENTITY(1, 1),
[CustomerID] [int] NULL,
[Shipping_NickName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Company] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Surname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Street] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Street2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Suburb] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_PostCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_FullName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Primary_Address] [bit] NOT NULL,
[Address_Type] [bit] NOT NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[szip_trim] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]