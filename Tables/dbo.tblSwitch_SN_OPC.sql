CREATE TABLE [dbo].[tblSwitch_SN_OPC]
(
[ordersProductsID] [int] NOT NULL,
[orderID] [int] NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fileName_front] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fileName_back] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[presentedToSwitch] [bit] NULL CONSTRAINT [DF_tblSwitch_SN_OPC_presentedToSwitch] DEFAULT ((0)),
[presentedToSwitch_on] [datetime] NULL,
[created_on] [datetime] NOT NULL CONSTRAINT [DF_tblSwitch_SN_OPC_created_on] DEFAULT (getdate()),
[modified_on] [datetime] NULL CONSTRAINT [DF_tblSwitch_SN_OPC_modified_on] DEFAULT (getdate()),
[customDataSynced] [bit] NULL CONSTRAINT [DF_tblSwitch_SN_OPC_dataSynced] DEFAULT ((0)),
[isPrepped] [bit] NOT NULL CONSTRAINT [DF_tblSwitch_SN_OPC_isPrepped] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitch_SN_OPC] ADD CONSTRAINT [PK_tblSwitch_SN_OPC] PRIMARY KEY CLUSTERED  ([ordersProductsID]) ON [PRIMARY]