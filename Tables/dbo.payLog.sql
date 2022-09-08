CREATE TABLE [dbo].[payLog]
(
[rowid] [int] NOT NULL IDENTITY(1, 1),
[orderid] [int] NULL,
[displayPaymentStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logdate] [datetime2] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[payLog] ADD CONSTRAINT [PK_payLog] PRIMARY KEY CLUSTERED ([rowid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_logDate] ON [dbo].[payLog] ([logdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderID] ON [dbo].[payLog] ([orderid]) ON [PRIMARY]