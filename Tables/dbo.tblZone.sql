CREATE TABLE [dbo].[tblZone]
(
[zipID] [int] NOT NULL,
[zip] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipZone] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GBSZone] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblZone] ADD CONSTRAINT [PK_tblZone] PRIMARY KEY CLUSTERED  ([zipID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBSZone] ON [dbo].[tblZone] ([GBSZone]) ON [PRIMARY]