CREATE TABLE [dbo].[tblTransactions]
(
[paymentID] [bigint] NOT NULL IDENTITY(9000000, 1),
[orderID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentAmount] [money] NULL,
[paymentDate] [datetime] NULL,
[responseCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseDesc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseSummary] [int] NULL,
[responseAmount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseRRN] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseOrderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseErrorDesc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseErrorNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseOtherInfo] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ipAddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardExpiry] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[processTime] [float] NULL,
[checkNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batchDate] [datetime] NULL,
[AuthorizationCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressVerificationStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InvoiceDescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActionCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deletex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tblTransactions_deletex] DEFAULT (0),
[dupe] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[verify] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mUpdated] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSU_status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[traceNumber] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responseFullCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTransactions] ADD CONSTRAINT [PK_tblTransactions] PRIMARY KEY NONCLUSTERED  ([paymentID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblTransactions_4] ON [dbo].[tblTransactions] ([ActionCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblTransactions_3] ON [dbo].[tblTransactions] ([AddressVerificationStatus]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblTransactions_2] ON [dbo].[tblTransactions] ([orderID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblTransactions_1] ON [dbo].[tblTransactions] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblTransactions] ON [dbo].[tblTransactions] ([paymentID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20150612-104720] ON [dbo].[tblTransactions] ([responseOrderNo]) ON [PRIMARY]