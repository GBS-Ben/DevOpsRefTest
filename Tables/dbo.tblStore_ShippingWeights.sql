CREATE TABLE [dbo].[tblStore_ShippingWeights]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[shippingID] [int] NULL,
[weightLower] [real] NULL,
[weightUpper] [real] NULL,
[fixedFee] [bit] NULL,
[amount] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_ShippingWeights] ADD CONSTRAINT [PK_tblStore_ShippingWeights] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]