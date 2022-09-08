CREATE TABLE [dbo].[tempJF_dataRequestKH_021617_01]
(
[orderID] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderTotal] [money] NULL,
[customerID] [int] NULL,
[OPID] [int] NOT NULL,
[productID] [int] NULL,
[productCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productQuantity] [int] NULL,
[productPrice] [money] NULL,
[infoLine01] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine02] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine03] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine04] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine05] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine06] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine07] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine08] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine09] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[infoLine10] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeTitle] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_fullName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customer_email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempJF_dataRequestKH_021617_01] ADD CONSTRAINT [PK_tempJF_dataRequestKH_021617_01] PRIMARY KEY CLUSTERED  ([OPID]) ON [PRIMARY]