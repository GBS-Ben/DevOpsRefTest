CREATE TABLE [dbo].[tblLocale]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[localeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[localeID] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLocale] ADD CONSTRAINT [PK_tblLocale] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]