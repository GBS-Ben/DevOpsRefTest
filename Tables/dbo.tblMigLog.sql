CREATE TABLE [dbo].[tblMigLog]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[migStamp] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[migTime] [datetime] NULL,
[archive] [bit] NOT NULL CONSTRAINT [DF_tblMigLog_archive] DEFAULT ((0)),
[migStoredProc] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[migNote] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMigLog] ADD CONSTRAINT [PK_tblMigLog] PRIMARY KEY CLUSTERED  ([pkid]) ON [PRIMARY]