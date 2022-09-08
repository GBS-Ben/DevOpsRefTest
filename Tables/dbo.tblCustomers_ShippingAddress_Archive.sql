CREATE TABLE [dbo].[tblCustomers_ShippingAddress_Archive]
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
[Primary_Address] [bit] NULL,
[Address_Type] [bit] NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[szip_trim] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_on] [datetime] NULL,
[modified_on] [datetime] NULL,
[isValidated] [bit] NULL,
[rdi] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[returnCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addrExists] [bit] NULL,
[UPSRural] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblCustomers_ShippingAddress_Archive] ([orderNo]) ON [PRIMARY]