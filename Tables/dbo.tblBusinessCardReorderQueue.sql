CREATE TABLE [dbo].[tblBusinessCardReorderQueue]
(
[BusinessCardReorderQueueKey] [int] NOT NULL IDENTITY(1, 1),
[OrderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderId] [int] NULL,
[OPID] [int] NULL,
[OrderEmail] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BusinessCardEmail] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReorderLink] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOrderDate] [datetime] NULL,
[DaysSinceLastOrder] [int] NULL,
[ImageUrl] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblBusinessCardReorderQueue] ADD CONSTRAINT [PK_tblBusinessCardReorderQueue] PRIMARY KEY CLUSTERED  ([BusinessCardReorderQueueKey]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblBusinessCardReorderQueue] ON [dbo].[tblBusinessCardReorderQueue] ([OPID], [BusinessCardEmail]) ON [PRIMARY]