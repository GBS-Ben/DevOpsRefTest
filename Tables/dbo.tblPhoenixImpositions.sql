CREATE TABLE [dbo].[tblPhoenixImpositions]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[xmlData] [xml] NOT NULL,
[ImpositionGUID] [uniqueidentifier] NULL,
[insertDate] [datetime2] NOT NULL CONSTRAINT [DF_tblPhoenixImpositions_insertDate] DEFAULT (getdate()),
[phoenixCreateDate] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phoenixID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[runLength] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[notes] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[client] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[defaultBleed] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dieCost] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[layoutCount] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[overrun] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[plateCost] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pressCost] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pressMinutes] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sheetUsage] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stockCost] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalCost] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[underrun] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[units] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[waste] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [CIndex_tblPhoenixImpositions] ON [dbo].[tblPhoenixImpositions] ([PKID], [ImpositionGUID]) ON [PRIMARY]