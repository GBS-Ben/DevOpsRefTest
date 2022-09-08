CREATE TABLE [dbo].[TempJagA]
(
[PKID] [int] NULL,
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID] [int] NULL,
[Surface1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Resubmit] [bit] NULL,
[Expedite] [bit] NULL,
[FirstInstance] [bit] NULL
) ON [PRIMARY]