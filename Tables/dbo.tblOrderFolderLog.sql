CREATE TABLE [dbo].[tblOrderFolderLog]
(
[ID] [int] NOT NULL,
[FolderGUID] [uniqueidentifier] NOT NULL,
[OrderId] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ordersProductsId] [int] NOT NULL,
[ProcessChannel] [int] NOT NULL,
[ProcessBeginDateTime] [datetime] NOT NULL CONSTRAINT [DF__tblOrderF__Proce__60381BF9] DEFAULT (getdate()),
[ProcessEndDateTime] [datetime] NULL,
[ProcessStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessError] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionJSON] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]