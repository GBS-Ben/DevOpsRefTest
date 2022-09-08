CREATE TABLE [dbo].[tblSwitch_NOP_NC_MarketCenterCodes]
(
[code] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [CI_code] ON [dbo].[tblSwitch_NOP_NC_MarketCenterCodes] ([code]) ON [PRIMARY]