﻿CREATE TABLE [dbo].[tempJF_AMZINV]
(
[sort] [int] NULL,
[sku] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempJF_AMZINV] ADD CONSTRAINT [PK_tempJF_AMZINV] PRIMARY KEY CLUSTERED  ([sku]) ON [PRIMARY]