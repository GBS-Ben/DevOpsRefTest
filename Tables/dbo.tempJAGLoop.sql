CREATE TABLE [dbo].[tempJAGLoop]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[SourceTable] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PKID] [int] NOT NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID] [int] NULL,
[Surface1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resubmit] [bit] NULL,
[Expedite] [bit] NULL,
[FirstInstance] [bit] NULL,
[IsInserted] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempJAGLoop] ADD CONSTRAINT [PK_PKID_LOOP] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]