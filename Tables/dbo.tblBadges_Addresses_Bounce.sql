CREATE TABLE [dbo].[tblBadges_Addresses_Bounce]
(
[sortNo] [int] NULL,
[shipName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipCompany] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeQTY] [int] NULL,
[pkid] [int] NOT NULL IDENTITY(1, 1),
[OPPO_ordersProductsID] [int] NULL
) ON [PRIMARY]