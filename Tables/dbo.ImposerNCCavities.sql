CREATE TABLE [dbo].[ImposerNCCavities]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPID] [int] NOT NULL,
[Surface1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resubmit] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities_Resubmit] DEFAULT ((0)),
[Expedite] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities_Expedite] DEFAULT ((0)),
[FirstInstance] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities_FirstInstance] DEFAULT ((0)),
[RowSort] [int] NULL,
[UV] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UVColor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BatchID] [int] NULL,
[ExpoSub] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities_JagExpoSub] DEFAULT ((0)),
[JagQTY] [int] NULL,
[JagUnder] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities_JagUnder] DEFAULT ((0)),
[JagSolo] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities_JagSolo] DEFAULT ((0)),
[JagOver] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavities_JagOverThreshold] DEFAULT ((0)),
[PKID_Old] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_JagSort] ON [dbo].[ImposerNCCavities] ([RowSort]) ON [PRIMARY]