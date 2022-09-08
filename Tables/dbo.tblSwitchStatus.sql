CREATE TABLE [dbo].[tblSwitchStatus]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[OPID] [int] NULL,
[pUnitID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[switchStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_on] [datetime] NOT NULL CONSTRAINT [DF_tblSwitchStatus_modified_on] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitchStatus] ADD CONSTRAINT [PK_tblSwitchStatus] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]