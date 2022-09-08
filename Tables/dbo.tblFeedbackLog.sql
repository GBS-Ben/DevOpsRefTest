CREATE TABLE [dbo].[tblFeedbackLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[userID] [int] NULL,
[userName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[feedbackCode] [int] NULL,
[feedbackCategory] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[feedbackDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[feedbackSeverity] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[feedbackNotes] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorNum] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorLine] [int] NULL,
[ASPErrorColumn] [int] NULL,
[ASPErrorDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorFullDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logDate] [datetime] NULL,
[resolved] [bit] NOT NULL CONSTRAINT [DF_tblFeedbackLog_resolved] DEFAULT (0),
[resolvedDate] [datetime] NULL,
[resolvedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[resolvedNotes] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblFeedbackLog] ADD CONSTRAINT [PK_tblFeedbackLog] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]