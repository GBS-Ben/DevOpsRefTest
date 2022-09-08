CREATE TABLE [dbo].[tblDashboard_Prop_JobTrack]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trackingNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trackSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailClass] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deliveredOn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pickupDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[signedForBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_StreetNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_StreetPrefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_StreetName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_StreetType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_StreetSuffix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_RoomSuiteFloor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_City] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_State] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_Zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tblOrders_modified_on] [datetime] NULL,
[tblOrders_Products_modified_on] [datetime] NULL,
[tblJobTrack_PKID] [int] NULL,
[modDiff] [bit] NULL,
[readyForProp] [int] NOT NULL CONSTRAINT [DF_tblDashboard_Prop_JobTrack_readyForProp] DEFAULT ((0)),
[weight] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDashboard_Prop_JobTrack] ADD CONSTRAINT [PK_tblDashboard_Prop_JobTrack] PRIMARY KEY NONCLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [cI_JT_PKID] ON [dbo].[tblDashboard_Prop_JobTrack] ([tblJobTrack_PKID]) ON [PRIMARY]