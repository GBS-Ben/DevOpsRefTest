CREATE TABLE [dbo].[tblNBA]
(
[sortNo] [int] NOT NULL IDENTITY(1, 1),
[Shipping_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Street] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Street2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_Suburb] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipping_PostCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeQTY] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]