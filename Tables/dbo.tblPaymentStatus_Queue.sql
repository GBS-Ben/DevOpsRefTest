CREATE TABLE [dbo].[tblPaymentStatus_Queue]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[processDateTime] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblPaymentStatus_Queue_orderNo] ON [dbo].[tblPaymentStatus_Queue] ([orderNo]) ON [PRIMARY]