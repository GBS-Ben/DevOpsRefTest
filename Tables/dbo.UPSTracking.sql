CREATE TABLE [dbo].[UPSTracking]
(
[TrackingID] [int] NOT NULL IDENTITY(1, 1),
[TrackingNumber] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrackingRequest] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AcquireInsertDateTime] [datetime2] NULL CONSTRAINT [DF_Tracking_AcquireInsertDateTime] DEFAULT (getdate()),
[ProcessExecutionId] [uniqueidentifier] NULL,
[ProcessStartDateTime] [datetime2] NULL,
[ProcessEndDateTime] [datetime2] NULL
) ON [PRIMARY]