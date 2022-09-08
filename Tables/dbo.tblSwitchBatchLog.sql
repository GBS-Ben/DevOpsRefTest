CREATE TABLE [dbo].[tblSwitchBatchLog]
(
[flowName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PKID] [int] NOT NULL,
[ordersProductsID] [int] NOT NULL,
[batchTimestamp] [datetime] NOT NULL,
[jsonData] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitchBatchLog] ADD CONSTRAINT [PK_tblSwitchBatchLog] PRIMARY KEY CLUSTERED  ([flowName], [PKID], [ordersProductsID], [batchTimestamp]) ON [PRIMARY]