CREATE TABLE [dbo].[tblCustomers_SavedCartsProductsOptions]
(
[poID] [int] NOT NULL IDENTITY(1, 1),
[saveID] [int] NULL,
[pID] [int] NULL,
[optionID] [int] NULL,
[textValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCustomers_SavedCartsProductsOptions] ADD CONSTRAINT [PK_tblCustomers_SavedCartsProductsOptions] PRIMARY KEY CLUSTERED  ([poID]) WITH (FILLFACTOR=90) ON [PRIMARY]