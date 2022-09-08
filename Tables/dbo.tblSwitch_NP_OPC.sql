CREATE TABLE [dbo].[tblSwitch_NP_OPC]
(
[ordersProductsID] [int] NOT NULL,
[orderID] [int] NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fileName_front] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[presentedToSwitch] [bit] NULL CONSTRAINT [DF_tblSwitch_NP_OPC_presentedToSwitch] DEFAULT ((0)),
[presentedToSwitch_on] [datetime] NULL
) ON [PRIMARY]