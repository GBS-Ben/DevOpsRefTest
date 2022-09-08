CREATE TABLE [dbo].[tblProducts_RelatedProducts]
(
[relatedID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NULL,
[relatedProductID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProducts_RelatedProducts] ADD CONSTRAINT [PK_tblProducts_RelatedProducts] PRIMARY KEY CLUSTERED  ([relatedID]) WITH (FILLFACTOR=90) ON [PRIMARY]