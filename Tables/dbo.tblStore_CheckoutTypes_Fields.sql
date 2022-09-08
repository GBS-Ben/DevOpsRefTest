CREATE TABLE [dbo].[tblStore_CheckoutTypes_Fields]
(
[checkoutTypeID] [int] NOT NULL,
[fieldText] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fieldName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fieldType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[required] [bit] NOT NULL
) ON [PRIMARY]