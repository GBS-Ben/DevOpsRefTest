CREATE TABLE [dbo].[tblSwitchEventLog]
(
[EventID] [int] NOT NULL IDENTITY(1, 1),
[flowName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PKID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordersProductsID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eventName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eventTimestamp] [datetime] NULL,
[jobName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[eventData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitchEventLog] ADD CONSTRAINT [PK_tblSwitchEventLog] PRIMARY KEY CLUSTERED  ([EventID]) ON [PRIMARY]