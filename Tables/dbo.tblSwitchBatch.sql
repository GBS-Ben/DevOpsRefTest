CREATE TABLE [dbo].[tblSwitchBatch]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[OPID] [int] NULL,
[batchNumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitchBatch] ADD CONSTRAINT [PK_tblSwitchBatch] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_BN] ON [dbo].[tblSwitchBatch] ([batchNumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OPID] ON [dbo].[tblSwitchBatch] ([OPID]) ON [PRIMARY]