﻿CREATE TABLE [dbo].[integers]
(
[i] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integers] ADD CONSTRAINT [PK_integers] PRIMARY KEY CLUSTERED  ([i]) ON [PRIMARY]