CREATE TABLE [dbo].[tblBadgesR2P]
(
[sortNo] [int] NULL,
[Contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BKGND] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHT] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POS] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COLogo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtextAll] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RO] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pkid] [int] NOT NULL IDENTITY(1, 1),
[OPPO_ordersProductsID] [int] NULL,
[QTY] [int] NULL,
[orderID] [int] NULL,
[productCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]