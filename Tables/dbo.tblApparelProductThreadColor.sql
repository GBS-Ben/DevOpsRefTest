CREATE TABLE [dbo].[tblApparelProductThreadColor]
(
[LoadDate] [datetime] NULL,
[CompanyName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sorting] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[APLogo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thread 1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thread 2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thread 3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thread 4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thread 5] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thread 6] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Thread 7] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LinkToLogo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Logo_INC_Threads] ON [dbo].[tblApparelProductThreadColor] ([APLogo]) INCLUDE ([Thread 1], [Thread 2], [Thread 3], [Thread 4], [Thread 5], [Thread 6], [Thread 7]) ON [PRIMARY]