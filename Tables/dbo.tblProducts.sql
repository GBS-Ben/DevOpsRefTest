CREATE TABLE [dbo].[tblProducts]
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
[onOrder] [int] NOT NULL CONSTRAINT [DF_tblProducts_onOrder_new] DEFAULT ((0)),
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
[inventoryCount] [int] NULL CONSTRAINT [DF_tblProducts_inventoryCount_new] DEFAULT ((0)),
[inventoryCountDate] [datetime] NOT NULL CONSTRAINT [DF_tblProducts_inventoryCountDate_new] DEFAULT ('01/01/1974'),
[parentProductID] [int] NULL,
[productMultiplier] [int] NULL,
[productCompany] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numUnits] [int] NULL,
[stock_Level] [int] NULL CONSTRAINT [DF_tblProducts_stock_Level_new] DEFAULT ((0)),
[INV_WIPHOLD_PHYS] [int] NULL CONSTRAINT [DF_tblProducts_INV_WIPHOLD_PHYS_new] DEFAULT ((0)),
[INV_ADJ] [int] NULL CONSTRAINT [DF_tblProducts_INV_ADJ_new] DEFAULT ((0)),
[INV_PS] [int] NULL CONSTRAINT [DF_tblProducts_INV_PS_new] DEFAULT ((0)),
[INV_WIPHOLD] [int] NULL CONSTRAINT [DF_tblProducts_INV_WIPHOLD_new] DEFAULT ((0)),
[INV_AVAIL] [int] NULL CONSTRAINT [DF_tblProducts_INV_AVAIL_new] DEFAULT ((0)),
[INV_ONHOLD_SOLO] [int] NULL CONSTRAINT [DF_tblProducts_INV_ONHOLD_SOLO_new] DEFAULT ((0)),
[INV_WIP_SOLO] [int] NULL CONSTRAINT [DF_tblProducts_INV_WIP_SOLO_new] DEFAULT ((0)),
[artBackgroundImageName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stream] [bit] NULL CONSTRAINT [DF_dbo_tblProducts_stream_new] DEFAULT ((0)),
[fastTrak] [bit] NULL CONSTRAINT [DF_tblProducts_fastTrack_new] DEFAULT ((0)),
[fastTrak_productType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subcontract] [bit] NOT NULL CONSTRAINT [DF_tblProducts_subcontract_new] DEFAULT ((0)),
[Source] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProducts] ADD CONSTRAINT [PK_tblProducts_new] PRIMARY KEY CLUSTERED ([productID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrack_productCode_INC_productID_fastTrackproductType] ON [dbo].[tblProducts] ([fastTrak], [productCode]) INCLUDE ([productID], [fastTrak_productType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrack_productCode_productType_INC_productID_fastTrackproductType] ON [dbo].[tblProducts] ([fastTrak], [productCode], [productType]) INCLUDE ([productID], [fastTrak_productType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_fasTrakProductType] ON [dbo].[tblProducts] ([fastTrak_productType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrakproductType_shortName_INC_productID_productName] ON [dbo].[tblProducts] ([fastTrak_productType], [shortName]) INCLUDE ([productID], [productName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_parentProductID] ON [dbo].[tblProducts] ([parentProductID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PC] ON [dbo].[tblProducts] ([productCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productCode_INC_parentproductid_numunits] ON [dbo].[tblProducts] ([productCode]) INCLUDE ([parentProductID], [numUnits]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PN] ON [dbo].[tblProducts] ([productName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productType] ON [dbo].[tblProducts] ([productType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productType_INC_productCode] ON [dbo].[tblProducts] ([productType]) INCLUDE ([productCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_subContract] ON [dbo].[tblProducts] ([subcontract]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_subcontract_INC_productID_productCode] ON [dbo].[tblProducts] ([subcontract]) INCLUDE ([productID], [productCode]) ON [PRIMARY]