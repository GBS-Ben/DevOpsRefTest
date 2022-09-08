CREATE TABLE [dbo].[BadgeLog]
(
[LastRun] [datetime2] NOT NULL CONSTRAINT [DF_BadgeLog_lastSuccessfulRun] DEFAULT (getdate())
) ON [PRIMARY]