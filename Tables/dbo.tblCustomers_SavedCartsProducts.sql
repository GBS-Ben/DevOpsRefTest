CREATE TABLE [dbo].[tblCustomers_SavedCartsProducts]
(
[pID] [int] NOT NULL IDENTITY(1, 1),
[saveID] [int] NULL,
[productID] [int] NULL,
[optionID] [int] NULL,
[quantity] [int] NULL,
[categoryID] [int] NULL,
[productPrice] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCustomers_SavedCartsProducts] ADD CONSTRAINT [PK_tblCustomers_SavedCartsProducts] PRIMARY KEY CLUSTERED  ([pID]) WITH (FILLFACTOR=90) ON [PRIMARY]