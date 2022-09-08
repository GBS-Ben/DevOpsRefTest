CREATE TABLE [dbo].[tblPrintFileMoverRegistration]
(
[PrintFileMoverRegistrationKey] [int] NOT NULL IDENTITY(1, 1),
[ProductDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductMask] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[optionCaption] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourcePath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationPath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationFilePattern] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ActiveFlag] [bit] NOT NULL
) ON [PRIMARY]