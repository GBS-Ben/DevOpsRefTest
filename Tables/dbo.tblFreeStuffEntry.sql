CREATE TABLE [dbo].[tblFreeStuffEntry]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[entryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[q1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[q2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insertDate] [datetime] NULL,
[entryFormID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPrefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]