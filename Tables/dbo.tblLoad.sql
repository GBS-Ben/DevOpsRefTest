CREATE TABLE [dbo].[tblLoad]
(
[lID] [int] NOT NULL IDENTITY(1, 1),
[loadID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loadTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblLoad] ADD CONSTRAINT [PK_tblLoad] PRIMARY KEY CLUSTERED  ([lID]) WITH (FILLFACTOR=90) ON [PRIMARY]