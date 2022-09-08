CREATE TABLE [dbo].[tblProducts_011922]
(
[productID] [int] NOT NULL IDENTITY(1, 1),
[productOnline] [bit] NOT NULL,
[canOrder] [bit] NOT NULL,
[productCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productIndex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productHeader] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shortName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shortDescription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[extendedDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[warranty] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[costPrice] [money] NULL,
[retailPrice] [money] NULL,
[salePrice] [money] NULL,
[no_shipping] [bit] NULL,
[downloadable] [int] NULL,
[downloadableFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[downloadableShipped] [bit] NOT NULL,
[downloadableDaysValid] [int] NULL,
[dateAvailable] [smalldatetime] NULL,
[onOrder] [int] NOT NULL CONSTRAINT [DF_tblProducts_onOrder] DEFAULT ((0)),
[stock_AutoReduce] [bit] NOT NULL,
[stock_LowNoOrder] [bit] NOT NULL,
[stock_LowLevel] [int] NULL,
[weight] [float] NULL,
[dimensionW] [float] NULL,
[dimensionH] [float] NULL,
[dimensionD] [float] NULL,
[manufacturer] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[supplierID] [int] NULL,
[imageThumbnail] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[image1] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[image1Large] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[image2] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[image2Large] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[image3] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[image3Large] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[placedInCartCount] [int] NULL,
[numberSoldCount] [int] NULL,
[viewCount] [int] NULL,
[soldValue] [money] NULL,
[status_mode] [int] NULL,
[status_auto_Low] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_auto_inStock] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status_man] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxApplies] [bit] NOT NULL,
[displayOrderGroup] [int] NULL,
[productType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[itemStyle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inventoryCount] [int] NULL CONSTRAINT [DF_tblProducts_inventoryCount] DEFAULT ((0)),
[inventoryCountDate] [datetime] NOT NULL CONSTRAINT [DF_tblProducts_inventoryCountDate] DEFAULT ('01/01/1974'),
[parentProductID] [int] NULL,
[productMultiplier] [int] NULL,
[productCompany] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numUnits] [int] NULL,
[stock_Level] [int] NULL CONSTRAINT [DF_tblProducts_stock_Level] DEFAULT ((0)),
[INV_WIPHOLD_PHYS] [int] NULL CONSTRAINT [DF_tblProducts_INV_WIPHOLD_PHYS] DEFAULT ((0)),
[INV_ADJ] [int] NULL CONSTRAINT [DF_tblProducts_INV_ADJ] DEFAULT ((0)),
[INV_PS] [int] NULL CONSTRAINT [DF_tblProducts_INV_PS] DEFAULT ((0)),
[INV_WIPHOLD] [int] NULL CONSTRAINT [DF_tblProducts_INV_WIPHOLD] DEFAULT ((0)),
[INV_AVAIL] [int] NULL CONSTRAINT [DF_tblProducts_INV_AVAIL] DEFAULT ((0)),
[INV_ONHOLD_SOLO] [int] NULL CONSTRAINT [DF_tblProducts_INV_ONHOLD_SOLO] DEFAULT ((0)),
[INV_WIP_SOLO] [int] NULL CONSTRAINT [DF_tblProducts_INV_WIP_SOLO] DEFAULT ((0)),
[artBackgroundImageName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stream] [bit] NULL CONSTRAINT [DF_dbo_tblProducts_stream] DEFAULT ((0)),
[fastTrak] [bit] NULL CONSTRAINT [DF_tblProducts_fastTrack] DEFAULT ((0)),
[fastTrak_productType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subcontract] [bit] NOT NULL CONSTRAINT [DF_tblProducts_subcontract] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProducts_011922] ADD CONSTRAINT [PK_tblProducts] PRIMARY KEY CLUSTERED ([productID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrack_productCode_INC_productID_fastTrackproductType] ON [dbo].[tblProducts_011922] ([fastTrak], [productCode]) INCLUDE ([productID], [fastTrak_productType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrack_productCode_productType_INC_productID_fastTrackproductType] ON [dbo].[tblProducts_011922] ([fastTrak], [productCode], [productType]) INCLUDE ([productID], [fastTrak_productType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_fasTrakProductType] ON [dbo].[tblProducts_011922] ([fastTrak_productType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrakproductType_shortName_INC_productID_productName] ON [dbo].[tblProducts_011922] ([fastTrak_productType], [shortName]) INCLUDE ([productID], [productName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_parentProductID] ON [dbo].[tblProducts_011922] ([parentProductID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PC] ON [dbo].[tblProducts_011922] ([productCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productCode_INC_parentproductid_numunits] ON [dbo].[tblProducts_011922] ([productCode]) INCLUDE ([parentProductID], [numUnits]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PN] ON [dbo].[tblProducts_011922] ([productName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productType] ON [dbo].[tblProducts_011922] ([productType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productType_INC_productCode] ON [dbo].[tblProducts_011922] ([productType]) INCLUDE ([productCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_subContract] ON [dbo].[tblProducts_011922] ([subcontract]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_subcontract_INC_productID_productCode] ON [dbo].[tblProducts_011922] ([subcontract]) INCLUDE ([productID], [productCode]) ON [PRIMARY]