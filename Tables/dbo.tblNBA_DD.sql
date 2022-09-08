CREATE TABLE [dbo].[tblNBA_DD]
(
[sortNo] [int] NOT NULL IDENTITY(1, 1),
[shipping_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_suburb] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_postCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeQTY] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortNo_seed] [int] NULL
) ON [PRIMARY]