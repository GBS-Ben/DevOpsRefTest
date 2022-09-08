CREATE TABLE [dbo].[tblKWMC]
(
[MCID] [int] NULL,
[MCName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCRegion] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCST] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCZip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OP] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TL] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[techSupport] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_MCID] ON [dbo].[tblKWMC] ([MCID]) WITH (FILLFACTOR=90) ON [PRIMARY]