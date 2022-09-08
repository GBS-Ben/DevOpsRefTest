CREATE TABLE [dbo].[tblSwitchControl]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[controlName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[controlStatus] [bit] NULL,
[printerID] [int] NOT NULL CONSTRAINT [DF_tblSwitchControl_printerID] DEFAULT ((1)),
[autoTriggerHour] [int] NULL,
[lastCheckedHour] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitchControl] ADD CONSTRAINT [PK_tblSwitchControl] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]