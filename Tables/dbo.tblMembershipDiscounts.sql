CREATE TABLE [dbo].[tblMembershipDiscounts]
(
[memberDiscountID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NULL,
[categoryID] [int] NULL,
[membershipID] [int] NULL,
[amount] [money] NULL,
[adjustmentType] [int] NULL,
[hidden] [bit] NOT NULL,
[noOrder] [bit] NOT NULL,
[noDiscount] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMembershipDiscounts] ADD CONSTRAINT [PK_tblMembershipDiscounts] PRIMARY KEY CLUSTERED  ([memberDiscountID]) WITH (FILLFACTOR=90) ON [PRIMARY]