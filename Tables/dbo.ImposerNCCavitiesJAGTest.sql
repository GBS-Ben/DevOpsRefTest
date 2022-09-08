CREATE TABLE [dbo].[ImposerNCCavitiesJAGTest]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPID] [int] NOT NULL,
[Surface1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resubmit] [bit] NOT NULL,
[Expedite] [bit] NOT NULL,
[FirstInstance] [bit] NOT NULL,
[RowSort] [int] NULL,
[UV] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UVColor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchID] [int] NULL,
[ExpoSub] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavitiesJAGTest_JagExpoSub] DEFAULT ((0)),
[JagQTY] [int] NULL,
[JagUnder] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavitiesJAGTest_JagUnder] DEFAULT ((0)),
[JagSolo] [bit] NOT NULL,
[JagOver] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavitiesJAGTest_JagOver] DEFAULT ((0))
) ON [PRIMARY]