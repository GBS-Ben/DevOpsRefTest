CREATE TABLE [dbo].[tblProducts_QuantityDiscounts]
(
[qtyDiscountID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NULL,
[qtyLower] [int] NULL,
[qtyUpper] [int] NULL,
[discountType] [tinyint] NULL,
[discountAmount] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProducts_QuantityDiscounts] ADD CONSTRAINT [PK_tblProducts_QuantityDiscounts] PRIMARY KEY CLUSTERED  ([qtyDiscountID]) WITH (FILLFACTOR=90) ON [PRIMARY]