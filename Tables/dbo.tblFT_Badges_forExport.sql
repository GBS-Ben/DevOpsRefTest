CREATE TABLE [dbo].[tblFT_Badges_forExport]
(
[template] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DDFname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputPath] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logFilePath] [nvarchar] (350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputStyle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputFormat] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtextAll] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RO] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fastTrak_shippingLabelOption1] [bit] NULL,
[fastTrak_shippingLabelOption2] [bit] NULL,
[fastTrak_shippingLabelOption3] [bit] NULL,
[fastTrak_resubmit] [bit] NULL,
[PKID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]