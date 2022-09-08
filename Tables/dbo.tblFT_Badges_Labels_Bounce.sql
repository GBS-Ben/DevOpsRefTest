CREATE TABLE [dbo].[tblFT_Badges_Labels_Bounce]
(
[sortNo] [int] NOT NULL,
[template] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DDFname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputPath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logFilePath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputStyle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputFormat] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipCompany] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shippingAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_City] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[badgeQTY] [int] NULL,
[PKID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]