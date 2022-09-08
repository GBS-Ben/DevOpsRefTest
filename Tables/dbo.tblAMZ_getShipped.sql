CREATE TABLE [dbo].[tblAMZ_getShipped]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[order-id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order-item-id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carrier-code] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[carrier-name] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tracking-number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ship-method] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amz_update] [bit] NULL CONSTRAINT [DF_tblAMZ_getShipped_amz_update] DEFAULT ((0)),
[date_conv] [bit] NOT NULL CONSTRAINT [DF_tblAMZ_getShipped_date_conv] DEFAULT ((0)),
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_tblAMZ_getShipped_dateCreated] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAMZ_getShipped] ADD CONSTRAINT [PK_tblAMZ_getShipped] PRIMARY KEY CLUSTERED  ([pkid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderID] ON [dbo].[tblAMZ_getShipped] ([order-id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderItemID] ON [dbo].[tblAMZ_getShipped] ([order-item-id]) ON [PRIMARY]