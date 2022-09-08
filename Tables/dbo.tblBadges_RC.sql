﻿CREATE TABLE [dbo].[tblBadges_RC]
(
[sortNo] [int] NULL,
[Contact] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BKGND] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHT] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POS] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COLogo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtextAll] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RO] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pkid] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblBadges_RC] ADD CONSTRAINT [PK_tblBadges_RC] PRIMARY KEY NONCLUSTERED  ([pkid]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IXRC] ON [dbo].[tblBadges_RC] ([sortNo]) WITH (FILLFACTOR=90) ON [PRIMARY]