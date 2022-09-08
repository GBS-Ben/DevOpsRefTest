CREATE TABLE [dbo].[tblCredits]
(
[creditID] [int] NOT NULL IDENTITY(1000000, 1),
[creditOrderID] [int] NULL,
[creditDesc] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[creditAmount] [money] NULL,
[DateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCredits] ADD CONSTRAINT [PK_tblCredits] PRIMARY KEY CLUSTERED  ([creditID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_COID] ON [dbo].[tblCredits] ([creditOrderID]) ON [PRIMARY]