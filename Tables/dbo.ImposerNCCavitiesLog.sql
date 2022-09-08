CREATE TABLE [dbo].[ImposerNCCavitiesLog]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPID] [int] NOT NULL,
[Surface1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resubmit] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavitiesLog_Resubmit] DEFAULT ((0)),
[Expedite] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavitiesLog_Expedite] DEFAULT ((0)),
[FirstInstance] [bit] NOT NULL CONSTRAINT [DF_ImposerNCCavitiesLog_FirstInstance] DEFAULT ((0)),
[RowSort] [int] NULL,
[UV] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UVColor] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertedOn] [datetime2] NOT NULL CONSTRAINT [DF_ImposerNCCavitiesLog_InsertedOn] DEFAULT (getdate()),
[ImpositionID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImposerNCCavitiesLog] ADD CONSTRAINT [PK_ImposerNCCavitiesLog] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]