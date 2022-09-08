CREATE TABLE [dbo].[tblStore_Shipping]
(
[shippingID] [int] NOT NULL IDENTITY(1, 1),
[method] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price] [money] NULL,
[taxApplies] [bit] NOT NULL,
[shippingTypeID] [int] NOT NULL,
[shippingTypeOptions] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_Shipping] ADD CONSTRAINT [PK_tblStore_Shipping] PRIMARY KEY CLUSTERED  ([shippingID]) WITH (FILLFACTOR=90) ON [PRIMARY]