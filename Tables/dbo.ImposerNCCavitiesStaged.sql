CREATE TABLE [dbo].[ImposerNCCavitiesStaged]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[PKID] [int] NOT NULL,
[PKID_Old] [int] NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPID] [int] NOT NULL,
[Surface1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resubmit] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities1_Resubmit] DEFAULT ((0)),
[Expedite] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities1_Expedite] DEFAULT ((0)),
[FirstInstance] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities1_FirstInstance] DEFAULT ((0)),
[RowSort] [int] NULL,
[UV] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UVColor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchID] [int] NULL,
[ExpoSub] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities1_JagExpoSub] DEFAULT ((0)),
[JagQTY] [int] NULL,
[JagUnder] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities1_JagUnder] DEFAULT ((0)),
[JagSolo] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities1_JagSolo] DEFAULT ((0)),
[JagOver] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities1_JagOverThreshold] DEFAULT ((0))
) ON [PRIMARY]