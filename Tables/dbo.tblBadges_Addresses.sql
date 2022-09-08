CREATE TABLE [dbo].[tblBadges_Addresses]
(
[sortNo] [int] NULL,
[shipName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipCompany] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeQTY] [int] NULL,
[OPPO_ordersproductsID] [int] NULL,
[pkid] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]