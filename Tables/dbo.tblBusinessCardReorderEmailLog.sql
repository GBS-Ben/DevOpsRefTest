CREATE TABLE [dbo].[tblBusinessCardReorderEmailLog]
(
[BusinessCardReorderEmailLogId] [int] NOT NULL IDENTITY(1, 1),
[DateEmailSent] [datetime2] NULL,
[ImageUrl] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReorderLink] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HTMLBody] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientEmail] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID] [int] NULL,
[OrderNo] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]