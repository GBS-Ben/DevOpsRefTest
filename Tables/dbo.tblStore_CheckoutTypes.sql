CREATE TABLE [dbo].[tblStore_CheckoutTypes]
(
[checkoutTypeID] [int] NOT NULL IDENTITY(1, 1),
[checkoutName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkoutDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkoutPage] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkoutBackendPage] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_CheckoutTypes] ADD CONSTRAINT [PK_tblStore_CheckoutTypes] PRIMARY KEY CLUSTERED  ([checkoutTypeID]) WITH (FILLFACTOR=90) ON [PRIMARY]