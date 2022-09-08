CREATE TABLE [dbo].[tblSearches]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[sessionID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchQuery] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchDateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSearches] ADD CONSTRAINT [PK_tblSearches] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]