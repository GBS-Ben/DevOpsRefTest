CREATE TABLE [dbo].[tblInfoBlocks]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[infoBlock] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unused] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]