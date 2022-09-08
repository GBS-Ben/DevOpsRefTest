CREATE TABLE [dbo].[tblArtBackgrounds]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productQuantity] [int] NULL,
[background] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_street2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_suburb] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_postCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customEnv] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[envFileName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[otherStock] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[otherCustom] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordersProductsID] [int] NULL,
[orderID] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_ORD] ON [dbo].[tblArtBackgrounds] ([ordersProductsID]) WITH (FILLFACTOR=90) ON [PRIMARY]