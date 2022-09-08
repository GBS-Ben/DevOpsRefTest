CREATE TABLE [dbo].[FurnishedArtEmailLog]
(
[OrderID] [int] NOT NULL,
[OrderNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[emailSent] [bit] NOT NULL,
[emailSentTo] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[emailSentOn] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo_inc_orderid] ON [dbo].[FurnishedArtEmailLog] ([OrderNo]) INCLUDE ([OrderID]) ON [PRIMARY]