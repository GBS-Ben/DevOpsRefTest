CREATE TABLE [dbo].[tblProducts_Categories]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NULL,
[categoryID] [int] NULL,
[hiddenInSearch] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProducts_Categories] ADD CONSTRAINT [PK_tblProducts_Categories] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblProducts_Categories] ON [dbo].[tblProducts_Categories] ([productID]) WITH (FILLFACTOR=90) ON [PRIMARY]