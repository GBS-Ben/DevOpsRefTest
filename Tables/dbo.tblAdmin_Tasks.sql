CREATE TABLE [dbo].[tblAdmin_Tasks]
(
[taskID] [int] NOT NULL IDENTITY(1, 1),
[taskDueDate] [datetime] NULL,
[task] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[complete] [bit] NOT NULL,
[archived] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAdmin_Tasks] ADD CONSTRAINT [PK_tblAdmin_Tasks] PRIMARY KEY CLUSTERED  ([taskID]) WITH (FILLFACTOR=90) ON [PRIMARY]