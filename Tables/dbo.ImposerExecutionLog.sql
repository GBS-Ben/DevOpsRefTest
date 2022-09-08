CREATE TABLE [dbo].[ImposerExecutionLog]
(
[ImpositionID] [int] NOT NULL IDENTITY(1000000, 1),
[ImpositionName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImpositionStartDate] [datetime2] NULL,
[ImpositionEndDate] [datetime2] NULL,
[StatusMessage] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isApplied] [bit] NOT NULL CONSTRAINT [DF_ImposerBatchExecutionLog_isApplied] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImposerExecutionLog] ADD CONSTRAINT [PK_ImposerBatchExecutionLog] PRIMARY KEY CLUSTERED  ([ImpositionID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_isApplied] ON [dbo].[ImposerExecutionLog] ([isApplied]) ON [PRIMARY]