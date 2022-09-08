CREATE TABLE [dbo].[tblCanvasFSW]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[parent] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StateFile] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[createdOn] [datetime] NOT NULL,
[FullPath] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[valid] [bit] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [C_INDEX_ID_STATEF_tblCanvasFSW] ON [dbo].[tblCanvasFSW] ([ID] DESC, [StateFile] DESC) ON [PRIMARY]