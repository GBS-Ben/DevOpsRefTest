CREATE TABLE [dbo].[FT_eventLog]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[eventType] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eventTime] [datetime] NULL,
[ordersProductsID] [int] NULL,
[orderNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]