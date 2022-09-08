CREATE TABLE [dbo].[tblINV_PO]
(
[poID] [int] NOT NULL IDENTITY(1, 1),
[poNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[enterDate] [datetime] NULL,
[expectDelivDate] [datetime] NULL,
[receiveDate] [datetime] NULL,
[source] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deletex] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblINV_PO] ADD CONSTRAINT [PK_tblINV_PO] PRIMARY KEY CLUSTERED  ([poID]) WITH (FILLFACTOR=90) ON [PRIMARY]