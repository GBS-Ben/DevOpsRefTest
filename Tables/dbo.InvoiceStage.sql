CREATE TABLE [dbo].[InvoiceStage]
(
[InvoiceStageId] [int] NOT NULL IDENTITY(1, 1),
[InvoiceNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvoiceStage] ADD CONSTRAINT [PK_InvoiceStage] PRIMARY KEY CLUSTERED  ([InvoiceStageId]) ON [PRIMARY]