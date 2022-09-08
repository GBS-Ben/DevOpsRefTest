CREATE TABLE [dbo].[testJF1234]
(
[jobNumber] [nvarchar] (57) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productcode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[material] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[size] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shape] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PKID] [int] NOT NULL,
[PKID_Remote] [int] NULL,
[ordersProductsID] [int] NULL,
[optionID] [int] NULL,
[optionCaption] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionPrice] [money] NULL,
[optionGroupCaption] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[textValue] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deletex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionQty] [int] NOT NULL,
[created_on] [datetime] NULL,
[modified_on] [datetime] NULL
) ON [PRIMARY]