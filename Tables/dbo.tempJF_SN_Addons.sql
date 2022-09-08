CREATE TABLE [dbo].[tempJF_SN_Addons]
(
[ordersProductsID] [int] NULL,
[optionCaption] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionPrice] [money] NULL,
[optionQty] [int] NOT NULL
) ON [PRIMARY]