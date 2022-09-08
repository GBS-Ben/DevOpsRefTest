CREATE TABLE [dbo].[ImposerNCReport]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[ImpositionID] [int] NULL,
[BatchID] [int] NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID] [int] NULL,
[uvType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShipType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportDate] [datetime] NOT NULL CONSTRAINT [DF_Table_1_reportDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImposerNCReport] ADD CONSTRAINT [PK_ImposerNCReport] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]