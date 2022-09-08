CREATE TABLE [dbo].[tblSwitch_OPID_TRON_RND]
(
[ID] [int] NOT NULL IDENTITY(1000, 1),
[OPID] [int] NOT NULL,
[ReadyForSwitch] [datetime] NOT NULL,
[ThresholdOfTime] [datetime] NULL
) ON [PRIMARY]