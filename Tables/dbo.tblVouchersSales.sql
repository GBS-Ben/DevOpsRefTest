CREATE TABLE [dbo].[tblVouchersSales]
(
[sVoucherID] [int] NOT NULL IDENTITY(1, 1),
[sVoucherCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sVoucherDiscountType] [tinyint] NULL,
[sVoucherAmount] [money] NULL,
[sVoucherComment] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dateCreated] [datetime] NULL,
[activationDate] [datetime] NULL,
[expiryDate] [datetime] NULL,
[sVoucherMinSpend] [money] NULL,
[isDeleted] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVouchersSales] ADD CONSTRAINT [PK_tblVouchersSales] PRIMARY KEY CLUSTERED  ([sVoucherID]) WITH (FILLFACTOR=90) ON [PRIMARY]