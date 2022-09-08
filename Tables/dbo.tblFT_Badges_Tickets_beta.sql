CREATE TABLE [dbo].[tblFT_Badges_Tickets_beta]
(
[template] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DDFname] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputPath] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logFilePath] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputStyle] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qty] [int] NULL,
[color] [int] NOT NULL,
[image] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frame] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[frame_symbol] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[templateFile] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPPO_ordersProductsID] [int] NOT NULL,
[productCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[resubmit] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fastTrak_shippingLabelOption1] [bit] NULL,
[fastTrak_shippingLabelOption2] [bit] NULL,
[fastTrak_shippingLabelOption3] [bit] NULL,
[fastTrak_resubmit] [bit] NULL
) ON [PRIMARY]