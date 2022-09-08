CREATE TABLE [dbo].[tblEmailsForms]
(
[ID] [int] NOT NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[text] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[editDate] [datetime] NULL,
[editor] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[version] [int] NULL,
[letter] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEmailsForms] ADD CONSTRAINT [PK_tblEmailsForms] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]