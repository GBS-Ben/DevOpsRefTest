CREATE TABLE [dbo].[tblCountry_Codes]
(
[ccID] [int] NOT NULL IDENTITY(1, 1),
[countryUPSName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryUPSCode] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryAUPostName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryAUPostCode] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryRevecomName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryRevecomCode] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryIntershipName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[countryIntershipCode] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCountry_Codes] ADD CONSTRAINT [PK_tblCountry_Codes] PRIMARY KEY CLUSTERED  ([ccID]) WITH (FILLFACTOR=90) ON [PRIMARY]