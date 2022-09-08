CREATE TABLE [dbo].[tblErrors]
(
[errorID] [int] NOT NULL IDENTITY(1, 1),
[errorDateTime] [datetime] NULL,
[errorNumber] [int] NULL,
[errorDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[errorSource] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[errorPage] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblErrors] ADD CONSTRAINT [PK_tblErrors] PRIMARY KEY CLUSTERED  ([errorID]) WITH (FILLFACTOR=90) ON [PRIMARY]