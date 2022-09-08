CREATE TABLE [dbo].[DRBILL_justEmails_ValidandSubbed]
(
[EMAIL] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [CLI_EMAIL] ON [dbo].[DRBILL_justEmails_ValidandSubbed] ([EMAIL]) ON [PRIMARY]