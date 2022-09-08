CREATE TABLE [dbo].[tblBadges]
(
[sortNo] [int] NULL,
[Contact] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BKGND] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POS] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COLogo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtextAll] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RO] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pkid] [int] NULL,
[OPPO_ordersProductsID] [int] NULL,
[QTY] [int] NULL,
[orderID] [int] NULL,
[productCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewModBadge] [bit] NOT NULL CONSTRAINT [DF_tblBadges_NewModBadge] DEFAULT ((0))
) ON [PRIMARY]