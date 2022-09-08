CREATE TABLE [dbo].[tblCountries]
(
[countryID] [int] NOT NULL IDENTITY(1, 1),
[countryName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryVisible] [bit] NOT NULL,
[countryDefault] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCountries] ADD CONSTRAINT [PK_tblCountries] PRIMARY KEY CLUSTERED  ([countryID]) WITH (FILLFACTOR=90) ON [PRIMARY]