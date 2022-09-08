CREATE TABLE [dbo].[tblVendor_Pens]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[POnumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY] [int] NULL,
[customerName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_City] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vProductCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vProductName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vPenColor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vImprintColor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vInkColor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vPricePerPiece] [decimal] (6, 4) NULL,
[OPC_file] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordersProductsID] [int] NULL
) ON [PRIMARY]