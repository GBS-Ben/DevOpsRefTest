CREATE TABLE [dbo].[tblCustomers_SavedCarts]
(
[saveID] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[saveNote] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[saveDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCustomers_SavedCarts] ADD CONSTRAINT [PK_tblCustomers_SavedCarts] PRIMARY KEY CLUSTERED  ([saveID]) WITH (FILLFACTOR=90) ON [PRIMARY]