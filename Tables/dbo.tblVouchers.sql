CREATE TABLE [dbo].[tblVouchers]
(
[voucherID] [int] NOT NULL IDENTITY(1, 1),
[voucherCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[voucherRecipient] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[initialAmount] [money] NULL,
[remainingAmount] [money] NULL,
[dateCreated] [datetime] NULL,
[orderID] [int] NULL,
[customerID] [int] NULL,
[isDeleted] [bit] NOT NULL,
[isPaid] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVouchers] ADD CONSTRAINT [PK_tblVouchers] PRIMARY KEY CLUSTERED  ([voucherID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OI] ON [dbo].[tblVouchers] ([orderID]) ON [PRIMARY]