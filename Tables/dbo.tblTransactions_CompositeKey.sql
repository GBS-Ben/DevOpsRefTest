CREATE TABLE [dbo].[tblTransactions_CompositeKey]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compositeKey] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ClusteredIndex-20160303-113534] ON [dbo].[tblTransactions_CompositeKey] ([compositeKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20160303-113558] ON [dbo].[tblTransactions_CompositeKey] ([orderNo]) ON [PRIMARY]