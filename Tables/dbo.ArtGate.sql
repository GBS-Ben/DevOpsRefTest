﻿CREATE TABLE [dbo].[ArtGate]
(
[OPID] [int] NOT NULL,
[InsertedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [CI_OPID] ON [dbo].[ArtGate] ([OPID]) ON [PRIMARY]