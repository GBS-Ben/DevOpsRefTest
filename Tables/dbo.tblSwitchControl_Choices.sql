CREATE TABLE [dbo].[tblSwitchControl_Choices]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[impositionChoice] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayedChoice] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitchControl_Choices] ADD CONSTRAINT [PK_tblSwitchControl_Choices] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]