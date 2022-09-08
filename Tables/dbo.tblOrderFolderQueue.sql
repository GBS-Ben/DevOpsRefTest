CREATE TABLE [dbo].[tblOrderFolderQueue]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[FolderGUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF__tblOrderF__Folde__5E4FD387] DEFAULT (newid()),
[orderId] [int] NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ordersProductsId] [int] NOT NULL,
[optionJSON] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]