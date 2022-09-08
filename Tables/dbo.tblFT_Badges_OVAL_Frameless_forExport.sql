CREATE TABLE [dbo].[tblFT_Badges_OVAL_Frameless_forExport]
(
[template] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DDFname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputPath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logfilePath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputStyle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputFormat] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Badge] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortNo] [int] NOT NULL IDENTITY(1, 1),
[ordersProductsID] [int] NULL,
[resubmit] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]