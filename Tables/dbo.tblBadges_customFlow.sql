CREATE TABLE [dbo].[tblBadges_customFlow]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[orderID] [int] NULL,
[orderNo] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordersProductsID] [int] NULL,
[lineCount] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backgroundColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[textColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frameColor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shape] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logo5] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[artInstructions] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insertDate] [datetime] NULL
) ON [PRIMARY]