CREATE TABLE [dbo].[tblFT_Badges_Labels]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[sortNo] [int] NOT NULL,
[template] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DDFname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputPath] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logFilePath] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputStyle] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputFormat] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipCompany] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shippingAddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Address2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_City] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Zip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeQTY] [int] NULL,
[OPPO_ordersProductsID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblFT_Badges_Labels] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]