CREATE TABLE [dbo].[tblINV_PO_Items]
(
[itemID] [int] NOT NULL IDENTITY(1, 1),
[poID] [int] NOT NULL,
[poNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productID] [int] NULL,
[productCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [int] NULL,
[price] [money] NULL,
[receiveDate] [datetime] NULL,
[status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deletex] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblINV_PO_Items] ADD CONSTRAINT [PK_tblINV_PO_Items1] PRIMARY KEY CLUSTERED  ([itemID]) WITH (FILLFACTOR=90) ON [PRIMARY]