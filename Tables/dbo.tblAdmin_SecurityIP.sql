CREATE TABLE [dbo].[tblAdmin_SecurityIP]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ipAddress] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAdmin_SecurityIP] ADD CONSTRAINT [PK_tblAdmin_SecurityIP] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]