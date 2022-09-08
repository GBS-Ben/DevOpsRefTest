CREATE TABLE [dbo].[logCheckJSON]
(
[opid] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[checkDate] [datetime] NULL,
[checkStatus] [bit] NOT NULL CONSTRAINT [DF_logCheckJSON_checkStatus] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_logCheckJSON] ON [dbo].[logCheckJSON] ([opid]) ON [PRIMARY]