CREATE TABLE [dbo].[tblKWleftOvers]
(
[fullName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TITLE] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MCID] [int] NULL,
[MCName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCRegion] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCST] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCZip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]