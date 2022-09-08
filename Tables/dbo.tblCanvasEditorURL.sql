CREATE TABLE [dbo].[tblCanvasEditorURL]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[ProductType] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CanvasURL] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCanvasEditorURL] ADD CONSTRAINT [PK_tblCanvasEditorURL] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]