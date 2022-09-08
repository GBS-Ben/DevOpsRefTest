CREATE TABLE [dbo].[tempJF_DirectoryTree]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[subdirectory] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[depth] [int] NULL,
[isfile] [bit] NULL
) ON [PRIMARY]