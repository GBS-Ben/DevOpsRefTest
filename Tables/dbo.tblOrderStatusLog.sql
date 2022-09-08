CREATE TABLE [dbo].[tblOrderStatusLog]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prev_orderStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrderStatusLog_prev_orderStatus] DEFAULT (N'New'),
[new_orderStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusChangeDate] [datetime] NULL CONSTRAINT [DF_tblOrderStatusLog_statusChangeDate] DEFAULT (getdate())
) ON [PRIMARY]