CREATE TABLE [dbo].[tblStore_Tax]
(
[taxID] [int] NOT NULL IDENTITY(1, 1),
[countryID] [int] NULL,
[stateID] [int] NULL,
[description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_Tax] ADD CONSTRAINT [PK_tblStore_Tax] PRIMARY KEY CLUSTERED  ([taxID]) WITH (FILLFACTOR=90) ON [PRIMARY]