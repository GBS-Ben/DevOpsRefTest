CREATE TABLE [dbo].[tblOPPO_BOUNCE]
(
[pkid] [int] NOT NULL IDENTITY(9000000, 1),
[ordersProductsID] [int] NULL,
[optionID] [int] NULL,
[optionCaption] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionPrice] [money] NULL,
[optionGroupCaption] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[textValue] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deletex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]