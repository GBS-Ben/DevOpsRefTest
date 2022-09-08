CREATE TABLE [dbo].[tblSwitch_Pens]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[POnumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [int] NULL,
[customerName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vProductCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vProductName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vPenColor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vImprintColor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vInkColor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vPricePerPiece] [decimal] (6, 4) NULL,
[calcPrice] [decimal] (18, 4) NULL,
[PDF] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordersProductsID] [int] NULL,
[subtotal] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]