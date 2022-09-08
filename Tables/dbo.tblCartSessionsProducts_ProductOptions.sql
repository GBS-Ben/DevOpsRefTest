CREATE TABLE [dbo].[tblCartSessionsProducts_ProductOptions]
(
[cartSession_Product_ID] [int] NULL,
[optionID] [int] NULL,
[textValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionPrice] [money] NULL
) ON [PRIMARY]