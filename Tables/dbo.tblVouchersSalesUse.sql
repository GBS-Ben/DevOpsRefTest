CREATE TABLE [dbo].[tblVouchersSalesUse]
(
[sVoucherUseID] [int] NOT NULL IDENTITY(1, 1),
[sVoucherID] [int] NULL,
[sVoucherCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderID] [int] NULL,
[sVoucherAmountApplied] [money] NULL,
[DiscountAmount] [money] NULL,
[vDateTime] [datetime] NULL,
[isDeleted] [bit] NOT NULL CONSTRAINT [DF_tblVouchersSalesUse_isDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVouchersSalesUse] ADD CONSTRAINT [PK_tblVouchersSalesUse] PRIMARY KEY CLUSTERED  ([sVoucherUseID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OID] ON [dbo].[tblVouchersSalesUse] ([orderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_sVoucherCode] ON [dbo].[tblVouchersSalesUse] ([sVoucherCode]) ON [PRIMARY]