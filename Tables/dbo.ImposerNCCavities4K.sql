CREATE TABLE [dbo].[ImposerNCCavities4K]
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
[FirstInstance] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImposerNCCavities4K] ADD CONSTRAINT [PK_ImposerNCCavities4K] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]