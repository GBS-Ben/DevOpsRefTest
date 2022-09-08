CREATE TABLE [dbo].[tbl_checks]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[inputdate] [datetime] NULL,
[method] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jobnumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checknumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [money] NULL,
[deletex] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bankName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tbl_checks] ADD CONSTRAINT [PK_tbl_checks] PRIMARY KEY CLUSTERED  ([pkid]) WITH (FILLFACTOR=90) ON [PRIMARY]