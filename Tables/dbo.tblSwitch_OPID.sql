CREATE TABLE [dbo].[tblSwitch_OPID]
(
[ID] [int] NOT NULL IDENTITY(1000, 1),
[OPID] [int] NOT NULL CONSTRAINT [DF_tblSwitch_OPID_OPID] DEFAULT ((0)),
[readyForSwitch] [datetime] NOT NULL CONSTRAINT [DF_tblSwitch_OPID_readyForSwitch] DEFAULT (getdate()),
[thresholdForSwitch] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitch_OPID] ADD CONSTRAINT [PK_tblSwitch_OPID] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_readyForSwitch] ON [dbo].[tblSwitch_OPID] ([readyForSwitch]) ON [PRIMARY]