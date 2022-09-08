CREATE TABLE [dbo].[tblCMSLogin]
(
[PKID] [bigint] NOT NULL IDENTITY(1, 1),
[username] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hashpassword] [varchar] (600) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]