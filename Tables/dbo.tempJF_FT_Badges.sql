﻿CREATE TABLE [dbo].[tempJF_FT_Badges]
(
[ordersProductsID] [int] NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[template] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DDFname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputPath] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputPath_Oval] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outpath_Rec] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logFilePath] [nvarchar] (350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputStyle] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputFormat] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtextAll] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortNo] [int] NULL,
[RO] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[alpha] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exportStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exportedOn] [datetime] NULL,
[notesWritten_imageFileCreation] [bit] NOT NULL,
[fastTrak_shippingLabelOption1] [bit] NULL,
[fastTrak_shippingLabelOption2] [bit] NULL,
[fastTrak_shippingLabelOption3] [bit] NULL,
[fastTrak_resubmit] [bit] NULL
) ON [PRIMARY]