CREATE TABLE [dbo].[tblVoucherUse]
(
[voucherUseID] [int] NOT NULL IDENTITY(1, 1),
[voucherID] [int] NULL,
[orderID] [int] NULL,
[valueApplied] [money] NULL,
[valueRemaining] [money] NULL,
[vDateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVoucherUse] ADD CONSTRAINT [PK_tblVoucherUse] PRIMARY KEY CLUSTERED  ([voucherUseID]) WITH (FILLFACTOR=90) ON [PRIMARY]