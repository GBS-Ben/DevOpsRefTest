CREATE TABLE [dbo].[tblPrintFileMoverLog]
(
[PrintFileMoverLogKey] [int] NOT NULL IDENTITY(1, 1),
[OrderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPID] [int] NOT NULL,
[optionCaption] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProcessDate] [datetime] NOT NULL,
[Status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]