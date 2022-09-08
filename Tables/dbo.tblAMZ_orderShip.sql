CREATE TABLE [dbo].[tblAMZ_orderShip]
(
[order-id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer-email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer-name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer-phone-number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recipient-name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-address-1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-address-2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-address-3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-postal-code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-phone-number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo_ID] [int] NOT NULL IDENTITY(123456, 1),
[orderStatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[storeID] [int] NOT NULL CONSTRAINT [DF_tblAMZ_orderShip_storeID] DEFAULT ((4)),
[docked_on] [datetime] NULL,
[shipped_on] [datetime] NULL,
[delivered_on] [datetime] NULL,
[modified_on] [datetime] NOT NULL CONSTRAINT [DF_tblAMZ_orderShip_modified_on] DEFAULT (getdate()),
[orderAck] [bit] NOT NULL CONSTRAINT [DF_tblAMZ_orderShip_orderAck] DEFAULT ((0)),
[orderBatchedDate] [datetime] NULL,
[orderPrintedDate] [datetime] NULL,
[isValidated] [bit] NULL,
[rdi] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[returnCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[addrExists] [bit] NULL,
[UPSRural] [bit] NULL,
[A1] [bit] NULL,
[A1_carrier] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A1_mailClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A1_mailPieceShape] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[A1_expediteShipFlag] [bit] NOT NULL CONSTRAINT [DF_tblAMZ_orderShip_A1_expediteShipFlag] DEFAULT ((0)),
[A1_processed] [bit] NOT NULL CONSTRAINT [DF_tblAMZ_orderShip_A1_processed] DEFAULT ((0)),
[A1_printed] [bit] NOT NULL CONSTRAINT [DF_tblAMZ_orderShip_A1_printed] DEFAULT ((0)),
[R2P] [bit] NOT NULL CONSTRAINT [DF_tblAMZ_orderShip_R2P] DEFAULT ((0)),
[A1_conditionID] [int] NULL,
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_tblAMZ_orderShip_dateCreated] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAMZ_orderShip] ADD CONSTRAINT [PK_tblAMZ_orderShip] PRIMARY KEY CLUSTERED  ([order-id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblAMZ_orderShip_A1] ON [dbo].[tblAMZ_orderShip] ([A1]) INCLUDE ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblAMZ_OrderShip_Isvalidated_A1_processed_A1] ON [dbo].[tblAMZ_orderShip] ([isValidated], [A1_processed], [A1]) INCLUDE ([orderNo], [orderNo_ID], [returnCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_AMZOrderShip_isValidated_rdi_a1_a1processed_a1printed] ON [dbo].[tblAMZ_orderShip] ([isValidated], [rdi], [A1], [A1_processed], [A1_printed]) INCLUDE ([orderNo], [returnCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderDate] ON [dbo].[tblAMZ_orderShip] ([orderDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblAMZ_orderShip] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderStatus_INC_order-id_orderNo_orderDate] ON [dbo].[tblAMZ_orderShip] ([orderStatus]) INCLUDE ([order-id], [orderNo], [orderDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblAMZ_orderShip_orderStatus] ON [dbo].[tblAMZ_orderShip] ([orderStatus]) INCLUDE ([orderNo], [orderDate], [buyer-name], [modified_on], [isValidated], [A1], [A1_carrier], [A1_mailClass], [A1_processed], [R2P], [A1_conditionID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_returnCode] ON [dbo].[tblAMZ_orderShip] ([returnCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_shipState] ON [dbo].[tblAMZ_orderShip] ([ship-state]) WITH (FILLFACTOR=90) ON [PRIMARY]