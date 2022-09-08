CREATE TABLE [dbo].[ImposerNCReportLog]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[ImpositionID] [int] NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID] [int] NULL,
[uvType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [datetime] NULL,
[InsertedOn] [datetime] NOT NULL CONSTRAINT [DF_ImposerNCReportLog_InsertedOn] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImposerNCReportLog] ADD CONSTRAINT [PK_ImposerNCReportLog] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]