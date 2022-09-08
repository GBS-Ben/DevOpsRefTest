CREATE TABLE [dbo].[tblChaseTransactions]
(
[PKID] [int] NOT NULL IDENTITY(111222333, 1),
[batchNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[merchantName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transactionDateTime] [datetime] NULL,
[reportingMerchantNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[batchClose] [date] NULL,
[seqNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardHolderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expDate] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[authCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryMode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[termOPID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transactionType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recordType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [money] NULL,
[currency] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[legacyTermID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PNSMerchNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sys] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalTime] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customData] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[routingNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[verified] [bit] NOT NULL CONSTRAINT [DF_tblChaseTransactions_verified] DEFAULT ((0)),
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_tblChaseTransactions_dateCreated] DEFAULT (getdate())
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20150513-120145] ON [dbo].[tblChaseTransactions] ([orderNo]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [ClusteredIndex-20150513-120123] ON [dbo].[tblChaseTransactions] ([rowID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160413-083301] ON [dbo].[tblChaseTransactions] ([verified]) ON [PRIMARY]