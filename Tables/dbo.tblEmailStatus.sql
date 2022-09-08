CREATE TABLE [dbo].[tblEmailStatus]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[pickupDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trackingNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipToAttention] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipToPhone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipToName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipToAddressLine1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipToAddressLine2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipToCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipToState] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipToZip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scheduledDeliveryDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[packageCount] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[packageWeight] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailStatus] [int] NULL,
[emailDate] [datetime] NULL,
[noteWritten] [bit] NULL CONSTRAINT [DF_tblEmailStatus_noteWritten] DEFAULT ((0)),
[noteWrittenDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEmailStatus] ADD CONSTRAINT [PK_tblEmailStatus] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_email] ON [dbo].[tblEmailStatus] ([email]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_emailDate_emailStatus_INC_orderNo] ON [dbo].[tblEmailStatus] ([emailDate], [emailStatus]) INCLUDE ([orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ IX_emailStatus] ON [dbo].[tblEmailStatus] ([emailStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_emailStatus_INC_orderNo_emailDate] ON [dbo].[tblEmailStatus] ([emailStatus]) INCLUDE ([orderNo], [emailDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_noteWritten] ON [dbo].[tblEmailStatus] ([noteWritten]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblEmailStatus] ([orderNo]) ON [PRIMARY]