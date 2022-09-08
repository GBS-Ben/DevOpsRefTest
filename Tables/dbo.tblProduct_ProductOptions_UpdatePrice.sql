CREATE TABLE [dbo].[tblProduct_ProductOptions_UpdatePrice]
(
[productID] [int] NOT NULL,
[optionID] [int] NOT NULL,
[optionGroupID] [int] NOT NULL,
[optionPrice] [money] NULL,
[optionDiscountApplies] [bit] NOT NULL
) ON [PRIMARY]