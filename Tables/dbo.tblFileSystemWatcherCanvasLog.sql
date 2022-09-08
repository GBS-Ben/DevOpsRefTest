CREATE TABLE [dbo].[tblFileSystemWatcherCanvasLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Parent] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StateFile] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedOn] [datetime] NOT NULL,
[FullPath] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Valid] [bit] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [C_INDEX_ID_STATEF_tblFileSystemWatcherCanvasLog] ON [dbo].[tblFileSystemWatcherCanvasLog] ([ID] DESC, [StateFile] DESC) ON [PRIMARY]