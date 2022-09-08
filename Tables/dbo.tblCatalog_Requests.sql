CREATE TABLE [dbo].[tblCatalog_Requests]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[visitor] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[repContact] [bit] NULL CONSTRAINT [DF_tblCatalog_Requests_repContact] DEFAULT ((0)),
[numberAgents] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[responsible] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[products] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comments] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reqDate] [datetime] NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reqForPrint] [bit] NULL CONSTRAINT [DF_tblCatalog_Requests_reqForPrint] DEFAULT ((0)),
[reqPrinted] [bit] NULL CONSTRAINT [DF_tblCatalog_Requests_reqPrinted] DEFAULT ((0)),
[printDate] [datetime] NULL,
[site] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblCatalog_Requests_site] DEFAULT ('HOM')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCatalog_Requests] ADD CONSTRAINT [PK_tblCatalog_Request] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]