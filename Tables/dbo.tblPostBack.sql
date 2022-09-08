CREATE TABLE [dbo].[tblPostBack]
(
[orderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trackingNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transactionID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postageAmount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address5] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address6] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zipCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[groupCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insuredValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insuranceFee] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fullXMLSource] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[length] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[width] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[height] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billedWeight] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[actualWeight] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postmarkDate] [datetime] NULL,
[transactionDatetime] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblPostBack] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]