CREATE TABLE [dbo].[SignMeta]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[char_12] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[char_52] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[size] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shape] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orientation] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SignMeta] ADD CONSTRAINT [PK_SignMeta] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]