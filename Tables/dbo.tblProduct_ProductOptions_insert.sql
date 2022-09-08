CREATE TABLE [dbo].[tblProduct_ProductOptions_insert]
(
[sku] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productID] [int] NULL,
[optionID] [int] NULL,
[optionGroupID] [int] NULL,
[PriceAdjustment] [numeric] (18, 4) NULL,
[optionDiscountApplies] [int] NULL,
[optionPrice] [money] NULL
) ON [PRIMARY]