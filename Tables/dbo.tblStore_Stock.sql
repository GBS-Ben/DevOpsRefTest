CREATE TABLE [dbo].[tblStore_Stock]
(
[ID] [int] NULL,
[stock_DisplayLevels] [bit] NOT NULL,
[stock_LowNotification] [bit] NOT NULL,
[stock_LowDisplay] [bit] NOT NULL,
[staffEmail1] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[staffEmail2] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[staffEmail3] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preOrder_Display] [bit] NOT NULL,
[preOrder_Order] [bit] NOT NULL
) ON [PRIMARY]