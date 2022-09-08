CREATE TABLE [dbo].[tblSwitchMerge_templateReference]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[productCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[templateBase] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fontColor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isVertical] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitchMerge_templateReference] ADD CONSTRAINT [PK_tblCA_templateReference] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]