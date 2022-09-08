CREATE TABLE [dbo].[StatusDPSTracker]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[orderID] [int] NULL,
[DPSupdatedToG2G] [bit] NOT NULL CONSTRAINT [DF_StatusDPSTracker_DPSupdate] DEFAULT ((0)),
[DPSupdatedToG2GOn] [datetime2] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StatusDPSTracker] ADD CONSTRAINT [PK_StatusDPSTracker] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]