CREATE TABLE [dbo].[tblOrders]
(
[orderID] [int] NOT NULL IDENTITY(1, 1),
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderAck] [bit] NULL,
[orderForPrint] [bit] NULL,
[orderJustPrinted] [bit] NULL,
[orderBatchedDate] [datetime] NULL,
[orderPrintedDate] [datetime] NULL,
[orderCancelled] [bit] NULL CONSTRAINT [DF_tblOrders_orderCancelled] DEFAULT ((0)),
[customerID] [int] NULL,
[membershipID] [int] NULL,
[membershipType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sessionID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[orderTotal] [money] NULL,
[taxAmountInTotal] [money] NULL,
[taxAmountAdded] [money] NULL,
[taxDescription] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shippingAmount] [money] NULL,
[shippingMethod] [int] NULL,
[shippingDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipDate] [datetime] NULL,
[feeAmount] [money] NULL,
[paymentAmountRequired] [money] NULL,
[paymentMethod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentMethodID] [int] NULL,
[paymentMethodRDesc] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentMethodIsCC] [bit] NULL,
[paymentMethodIsSC] [bit] NULL,
[cardNumber] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardExpiryMonth] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardExpiryYear] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardType] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardCCV] [nvarchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardStoreInfo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Surname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Street2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_PostCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_Phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blindShip] [bit] NULL CONSTRAINT [DF_tblOrders_blindShip] DEFAULT ((0)),
[specialInstructions] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentProcessed] [bit] NULL,
[paymentProcessedDate] [datetime] NULL,
[paymentSuccessful] [bit] NULL,
[ipAddress] [nvarchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[referrer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[archived] [bit] NULL,
[messageToCustomer] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reasonforpurchase] [varchar] (355) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusTemp] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusDate] [datetime] NULL,
[orderType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrders_orderType] DEFAULT ('Stock'),
[emailStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrders_emailStatus] DEFAULT ((1)),
[actMigStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tabStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tblOrders_tabStatus] DEFAULT ('new'),
[importFlag] [int] NULL CONSTRAINT [DF_tblOrders_importFlag] DEFAULT ((0)),
[specialOffer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[storeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrders_storeID] DEFAULT ('HOM'),
[coordIDUsed] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brokerOwnerIDUsed] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[importDate] [datetime] NULL,
[invRefDate] [datetime] NULL,
[repName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowUpdate] [timestamp] NULL,
[grpOrder] [bit] NULL CONSTRAINT [DF_tblOrders_grpOrder] DEFAULT ((0)),
[lastStatusUpdate] [datetime] NULL,
[promoName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sampler] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_tblOrders_sampler] DEFAULT ('no'),
[shipZone] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResCom] [char] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderWeight] [float] NULL,
[com] [float] NULL,
[res] [float] NULL,
[aReg] [float] NULL,
[bReg] [float] NULL,
[a1] [bit] NOT NULL CONSTRAINT [DF_tblOrders_a1] DEFAULT ((0)),
[stockShipFirst] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calcOrderTotal] [money] NULL,
[calcTransTotal] [money] NULL,
[calcProducts] [money] NULL,
[calcOPPO] [money] NULL,
[calcVouchers] [money] NULL,
[calcCredits] [money] NULL,
[calcBadges] [int] NULL,
[displayPaymentStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_on] [datetime] NULL CONSTRAINT [DF_tblOrders_lastUpdate] DEFAULT (getdate()),
[modified_on] [datetime] NULL CONSTRAINT [DF__tblOrders__modif__3A06A5CC] DEFAULT (getdate()),
[billingAddressID] [int] NULL,
[billing_Company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_FirstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Surname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Street2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_PostCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[billing_Phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cartVersion] [int] NULL,
[shippingAddressID] [int] NULL,
[a1_expediteShipFlag] [bit] NULL CONSTRAINT [DF_tblOrders_A1_expediteShipFlag] DEFAULT ((0)),
[billingReference] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a1_carrier] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a1_mailClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a1_mailPieceShape] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[a1_processed] [bit] NOT NULL CONSTRAINT [DF_tblOrders_a1_processed] DEFAULT ((0)),
[a1_printed] [bit] NOT NULL CONSTRAINT [DF_tblOrders_a1_printed] DEFAULT ((0)),
[cubic] [bit] NOT NULL CONSTRAINT [DF_tblOrders_cubic] DEFAULT ((0)),
[a1_conditionID] [int] NULL,
[R2P] [bit] NOT NULL CONSTRAINT [DF_tblOrders_R2P] DEFAULT ((0)),
[NOP] [bit] NOT NULL CONSTRAINT [DF_tblOrders_NOP] DEFAULT ((0)),
[ArrivalDate] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOrders] ADD CONSTRAINT [PK_tblOrders] PRIMARY KEY CLUSTERED ([orderID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_a1] ON [dbo].[tblOrders] ([a1]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_A1] ON [dbo].[tblOrders] ([a1]) INCLUDE ([orderNo], [storeID], [orderWeight]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_a1_orderStatus] ON [dbo].[tblOrders] ([a1], [orderStatus]) INCLUDE ([orderID], [rowUpdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderstatus_orderdate_INC_rowupdate_shippingdesc] ON [dbo].[tblOrders] ([a1_expediteShipFlag], [orderStatus], [orderDate]) INCLUDE ([shippingDesc], [rowUpdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_archived_orderStatus_inc_orderNo_customerID] ON [dbo].[tblOrders] ([archived], [orderStatus]) INCLUDE ([orderNo], [customerID], [orderDate], [storeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_archived_orderStatus_tabStatus] ON [dbo].[tblOrders] ([archived], [orderStatus], [tabStatus]) INCLUDE ([storeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders.customerID] ON [dbo].[tblOrders] ([customerID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_displayPaymentStatus_OrderStatus] ON [dbo].[tblOrders] ([displayPaymentStatus], [orderStatus]) INCLUDE ([orderID], [orderNo], [customerID], [orderDate], [sampler], [created_on], [modified_on]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_membershipType] ON [dbo].[tblOrders] ([membershipType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_NOP] ON [dbo].[tblOrders] ([NOP]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Orders_NOP_OrderDate_Status] ON [dbo].[tblOrders] ([NOP], [orderDate], [status]) INCLUDE ([orderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrderAck_archived_ordertype_orderstatus_tabstatus] ON [dbo].[tblOrders] ([orderAck], [archived], [orderType], [orderStatus], [tabStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_orderAck_paymentProcessed_paymentSuccessful_archived_orderType_tabStatus_orderStatus] ON [dbo].[tblOrders] ([orderAck], [paymentProcessed], [paymentSuccessful], [archived], [orderType], [tabStatus], [orderStatus]) INCLUDE ([customerID], [storeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DATE] ON [dbo].[tblOrders] ([orderDate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_OrderDateOrderStatus] ON [dbo].[tblOrders] ([orderDate], [orderStatus]) INCLUDE ([customerID], [orderTotal], [paymentMethod], [calcOrderTotal]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_displayPaymentStatus_orderDate_orderStatus_INC_orderID_orderNO_customerID_createdon] ON [dbo].[tblOrders] ([orderDate], [orderStatus], [displayPaymentStatus]) INCLUDE ([orderID], [orderNo], [customerID], [created_on]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblOrders.orderNo] ON [dbo].[tblOrders] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderStatus_Inc_orderID_orderNo_customerID_orderDate_orderTotal] ON [dbo].[tblOrders] ([orderStatus]) INCLUDE ([orderID], [orderNo], [customerID], [orderDate], [orderTotal]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_orderStatus] ON [dbo].[tblOrders] ([orderStatus]) INCLUDE ([orderNo], [customerID], [orderDate], [shippingAmount], [shipDate], [paymentProcessedDate], [calcOrderTotal], [calcTransTotal], [calcProducts], [calcOPPO], [calcVouchers], [calcCredits]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders.orderStatus] ON [dbo].[tblOrders] ([orderStatus]) INCLUDE ([orderNo], [rowUpdate]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderStatus_orderNO_paymentMethodID_Inc_orderID] ON [dbo].[tblOrders] ([orderStatus], [orderNo], [paymentMethodID]) INCLUDE ([orderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderStatus_tabStatus_INC_orderID_orderNo_lastStatusUpdate] ON [dbo].[tblOrders] ([orderStatus], [tabStatus]) INCLUDE ([orderID], [orderNo], [lastStatusUpdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblORders_Status] ON [dbo].[tblOrders] ([orderStatus], [tabStatus]) INCLUDE ([orderID], [orderNo], [rowUpdate], [lastStatusUpdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderType] ON [dbo].[tblOrders] ([orderType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderType_inc_orderID_orderNo_created_on] ON [dbo].[tblOrders] ([orderType]) INCLUDE ([orderID], [orderNo], [created_on]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_orderType] ON [dbo].[tblOrders] ([orderType]) INCLUDE ([orderID], [orderNo], [rowUpdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_orderWeight_com_res_aReg_bReg_INC_orderID_orderNo_orderDate_rowUpdate] ON [dbo].[tblOrders] ([orderWeight], [com], [res], [aReg], [bReg]) INCLUDE ([orderID], [orderNo], [orderDate], [rowUpdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_paymentSuccessful_archived_orderStatus_tabStatus] ON [dbo].[tblOrders] ([paymentSuccessful], [archived], [orderStatus], [tabStatus]) INCLUDE ([customerID], [paymentProcessed], [storeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_ResCom_OrderNoRowUpdate] ON [dbo].[tblOrders] ([ResCom]) INCLUDE ([orderNo], [rowUpdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_shippingAddressID_INC_orderNo] ON [dbo].[tblOrders] ([shippingAddressID]) INCLUDE ([orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders.storeID] ON [dbo].[tblOrders] ([storeID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_tabStatus_orderStatus] ON [dbo].[tblOrders] ([tabStatus], [orderStatus]) ON [PRIMARY]
GO
CREATE TRIGGER [dbo].[trg_update_tblOrders] on [dbo].[tblOrders] 
FOR UPDATE AS            
BEGIN
    UPDATE o
    SET modified_on = GETDATE(), 
	lastStatusUpdate = 	CASE WHEN o.orderStatus <> d.orderStatus THEN GETDATE() ELSE o.lastStatusUpdate END
    FROM tblOrders o
	INNER JOIN deleted d
		ON o.[orderID] = d.[orderID]

 --   UPDATE tblOrders
 --   SET lastStatusUpdate = GETDATE()
 --   FROM deleted
 --   WHERE 
	--tblOrders.orderID = deleted.orderID
	--	AND tblOrders.orderStatus <> deleted.orderStatus

	UPDATE tblOrderView
	SET tabStatus = b.tabStatus,
		orderTotal = b.orderTotal,
		orderStatus = b.orderStatus,
		lastStatusUpdate = b.lastStatusUpdate,
		modified_on = GETDATE()
	FROM tblOrderView a 
	INNER JOIN tblOrders b
		ON a.orderNo = b.orderNo
	INNER JOIN deleted d
		ON b.orderID = d.orderID

	insert into dbo.tblEntityStatus (EntityId,EntityName,StatusType,[Status],StatusDate)
	select o.orderID,'Orders','Order Status',o.orderStatus,getdate()
	from dbo.tblOrders o
	inner join deleted d
		on o.orderID = d.orderID
	where o.orderStatus <> d.orderStatus

	-- add to entity log
		DECLARE  @LogID TABLE (LogID BIGINT, EntityID int, CreatedOn datetime);

		INSERT INTO tblEntityLog (EntityID,EntityTypeID,LogTypeID,LogDateTime,CreatedBy)
		OUTPUT inserted.LogID, inserted.EntityID, inserted.CreatedOn INTO @LogID
		SELECT d.orderid, (SELECT EntityTypeID FROM tblEntityType WHERE EntityType = 'Order'), (SELECT LogTypeID FROM tblEntityLogType WHERE LogType = 'Status Change'), getdate(),suser_sname()
		FROM deleted d
		inner join tblOrders o on d.orderID = o.orderID
		where  o.orderStatus <> d.orderStatus
		
		INSERT INTO tblEntityLogInfo (LogID, LogInfo, CreatedBy, CreatedOn)
		SELECT LogID, i.orderStatus, suser_sname(), CreatedOn
		FROM @LogID l
		INNER JOIN inserted i on l.EntityID = i.orderID

END
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'reasonforpurchase'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'shipping_Company'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'shipping_Country'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'shipping_FirstName'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'shipping_Phone'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'shipping_PostCode'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'shipping_State'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'shipping_Street'
GO
EXEC sp_addextendedproperty N'MS_Description', N'NOT USED', 'SCHEMA', N'dbo', 'TABLE', N'tblOrders', 'COLUMN', N'shipping_Suburb'