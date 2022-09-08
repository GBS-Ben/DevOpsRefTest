CREATE TABLE [dbo].[tblStore_ShippingCountries]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[shippingID] [int] NULL,
[countryID] [int] NULL,
[stateID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_ShippingCountries] ADD CONSTRAINT [PK_tblStore_ShippingCountries] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]