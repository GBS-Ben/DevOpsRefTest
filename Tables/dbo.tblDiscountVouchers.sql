CREATE TABLE [dbo].[tblDiscountVouchers]
(
[dVoucherID] [int] NOT NULL IDENTITY(1, 1),
[dVoucherCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dVoucherAmount] [money] NULL,
[dateCreated] [datetime] NULL,
[expiryDate] [smalldatetime] NULL,
[minSpend] [money] NULL,
[voucherUsed] [bit] NOT NULL,
[orderID] [int] NULL,
[isDeleted] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDiscountVouchers] ADD CONSTRAINT [PK_tblDiscountVouchers] PRIMARY KEY CLUSTERED  ([dVoucherID]) WITH (FILLFACTOR=90) ON [PRIMARY]