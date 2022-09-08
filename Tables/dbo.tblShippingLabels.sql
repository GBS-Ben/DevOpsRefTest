CREATE TABLE [dbo].[tblShippingLabels]
(
[PKID] [int] NOT NULL IDENTITY(1000, 1),
[mailClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weightOz] [numeric] (18, 2) NULL,
[mailpieceShape] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipDate] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referenceID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[storeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[getLabel] [bit] NULL CONSTRAINT [DF_tblShippingLabels_labelGenerated] DEFAULT ((0)),
[getLabelDate] [datetime] NULL,
[labelName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labelPath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trackingNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblShippingLabels] ADD CONSTRAINT [PK_tblShippingLabels] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_getLabel] ON [dbo].[tblShippingLabels] ([getLabel]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_referenceID] ON [dbo].[tblShippingLabels] ([referenceID]) ON [PRIMARY]