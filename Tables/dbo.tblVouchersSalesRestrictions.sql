CREATE TABLE [dbo].[tblVouchersSalesRestrictions]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[sVoucherID] [int] NULL,
[productID] [int] NULL,
[categoryID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVouchersSalesRestrictions] ADD CONSTRAINT [PK_tblVouchersSalesRestrictions] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]