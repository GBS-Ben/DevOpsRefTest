CREATE TABLE [dbo].[tblFT_badges_rec_02]
(
[template] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DDFname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[outputPath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logFilePath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[outputStyle] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Badge] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortNo] [int] NULL
) ON [PRIMARY]