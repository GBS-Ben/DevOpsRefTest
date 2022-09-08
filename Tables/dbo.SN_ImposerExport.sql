CREATE TABLE [dbo].[SN_ImposerExport]
(
[jobnumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opid] [int] NULL,
[material] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[size] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shape] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]