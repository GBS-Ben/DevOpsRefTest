CREATE TABLE [dbo].[tblReports]
(
[PKID] [bigint] NOT NULL IDENTITY(1, 1),
[query] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[url] [varchar] (600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vardata] [bit] NULL,
[varname] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vardatanum] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reportName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]