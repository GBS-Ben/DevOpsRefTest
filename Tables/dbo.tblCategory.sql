CREATE TABLE [dbo].[tblCategory]
(
[categoryID] [int] NOT NULL IDENTITY(1, 1),
[parentID] [int] NULL,
[categoryName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryShortDescription] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[categoryImage] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discountPercent] [real] NULL,
[hidden] [bit] NOT NULL,
[noOrder] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCategory] ADD CONSTRAINT [PK_tblCategory] PRIMARY KEY CLUSTERED  ([categoryID]) WITH (FILLFACTOR=90) ON [PRIMARY]