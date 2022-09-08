CREATE TABLE [dbo].[tblEndiciaPostBack]
(
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailClass] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postageAmount] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trackingNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postMarkDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transactionDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transactionID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[groupCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insuredValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insuranceFee] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[length] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[width] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[height] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[companyName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[attention] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS3] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS4] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS5] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS6] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS7] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS8] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS9] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RS10] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jobTrack_migStamp] [datetime] NULL,
[PKID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEndiciaPostBack] ADD CONSTRAINT [PK_tblEndiciaPostBack] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblEndiciaPostBack_OrderNo] ON [dbo].[tblEndiciaPostBack] ([orderNo]) INCLUDE ([trackingNo], [transactionDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblEndiciaPostBack_TrackingNo] ON [dbo].[tblEndiciaPostBack] ([trackingNo]) INCLUDE ([orderNo], [transactionDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_jobTrack_migStamp_transactionID] ON [dbo].[tblEndiciaPostBack] ([transactionID], [jobTrack_migStamp]) ON [PRIMARY]