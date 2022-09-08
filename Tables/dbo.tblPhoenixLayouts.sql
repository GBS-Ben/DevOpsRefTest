CREATE TABLE [dbo].[tblPhoenixLayouts]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[impositionGUID] [uniqueidentifier] NULL,
[layoutGUID] [uniqueidentifier] NULL,
[insertDate] [datetime2] NOT NULL CONSTRAINT [DF_tblPhoenixLayouts_insertDate] DEFAULT (getdate()),
[phoenixLayoutID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[layoutIndex] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[runLength] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[client] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[defaultBleed] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dieCost] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[layoutCount] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[overrun] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plateCost] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pressCost] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pressMinutes] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sheetUsage] [nvarchar] (39) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockCost] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalCost] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[underrun] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[units] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[waste] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [CIndex_tblPhoenixLayouts] ON [dbo].[tblPhoenixLayouts] ([PKID], [impositionGUID], [layoutGUID]) ON [PRIMARY]