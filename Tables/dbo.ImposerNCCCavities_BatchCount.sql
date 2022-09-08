CREATE TABLE [dbo].[ImposerNCCCavities_BatchCount]
(
[BatchID] [int] NULL,
[CurrentCount] [int] NULL CONSTRAINT [DF_ImposerNCCCavities_BatchCount_CurrentCount] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [CI_batchID] ON [dbo].[ImposerNCCCavities_BatchCount] ([BatchID]) ON [PRIMARY]