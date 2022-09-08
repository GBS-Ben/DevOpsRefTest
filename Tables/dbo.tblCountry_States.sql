CREATE TABLE [dbo].[tblCountry_States]
(
[stateID] [int] NOT NULL IDENTITY(1, 1),
[countryID] [int] NULL,
[stateName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCountry_States] ADD CONSTRAINT [PK_tblCountry_States] PRIMARY KEY CLUSTERED  ([stateID]) WITH (FILLFACTOR=90) ON [PRIMARY]