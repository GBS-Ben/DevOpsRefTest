CREATE TABLE [dbo].[BatchPrintStatus]
(
[flowName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[batchTimestamp] [datetime] NOT NULL,
[batchPrintedDate] [datetime] NULL
) ON [PRIMARY]