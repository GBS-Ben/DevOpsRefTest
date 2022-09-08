CREATE TABLE [dbo].[tblStore_ShippingTypes]
(
[shippingTypeID] [int] NOT NULL IDENTITY(1, 1),
[shippingTypeName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shippingTypeDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionOne] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionTwo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionThree] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionFour] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_ShippingTypes] ADD CONSTRAINT [PK_tblStore_ShippingTypes] PRIMARY KEY CLUSTERED  ([shippingTypeID]) WITH (FILLFACTOR=90) ON [PRIMARY]