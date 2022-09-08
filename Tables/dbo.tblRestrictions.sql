CREATE TABLE [dbo].[tblRestrictions]
(
[restrictionID] [int] NOT NULL IDENTITY(1, 1),
[countryID] [int] NULL,
[stateID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRestrictions] ADD CONSTRAINT [PK_tblRestrictions] PRIMARY KEY CLUSTERED  ([restrictionID]) WITH (FILLFACTOR=90) ON [PRIMARY]