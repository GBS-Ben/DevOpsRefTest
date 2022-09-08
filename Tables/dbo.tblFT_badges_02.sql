CREATE TABLE [dbo].[tblFT_badges_02]
(
[template] [nvarchar] (329) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DDFname] [varchar] (26) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputPath] [nvarchar] (295) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logFilePath] [nvarchar] (296) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputStyle] [varchar] (26) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[contact] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtextAll] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RO] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPPO_ordersProductsID] [int] NULL,
[alpha] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]