CREATE TABLE [dbo].[DBChangeLog]
(
[DBChangeID] [int] NOT NULL IDENTITY(1, 1),
[DBName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DBObject] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChangeDescription] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ChangeDateTime] [datetime] NOT NULL CONSTRAINT [DF_DBChangeLog_ChangeDateTime] DEFAULT (getdate())
) ON [PRIMARY]