CREATE TABLE [dbo].[tblKWA]
(
[MCID] [int] NULL,
[agentID] [int] NOT NULL IDENTITY(1, 1),
[firstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fullName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[homeAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[homeCity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[homeST] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[homeZip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[homePhone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OP] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MCA] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[techSupport] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[leftOver] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_AgentID] ON [dbo].[tblKWA] ([agentID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Email] ON [dbo].[tblKWA] ([email]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MCID] ON [dbo].[tblKWA] ([MCID]) WITH (FILLFACTOR=90) ON [PRIMARY]