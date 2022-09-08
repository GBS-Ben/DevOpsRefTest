CREATE TABLE [dbo].[tblVisitorsAdmin]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[userName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aDateTime] [datetime] NULL,
[ipAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pageAccessed] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVisitorsAdmin] ADD CONSTRAINT [PK_tblVisitorsAdmin] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]