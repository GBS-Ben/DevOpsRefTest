CREATE TABLE [dbo].[ImposerRowSort]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[PKID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImposerRowSort] ADD CONSTRAINT [PK_PKID] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]