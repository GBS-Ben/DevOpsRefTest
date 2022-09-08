CREATE TABLE [dbo].[tblOrders_Products] (
    [ID]                            INT              IDENTITY (900000, 1) NOT NULL,
    [orderID]                       INT              NULL,
    [productID]                     INT              NULL,
    [optionID]                      INT              NULL,
    [productName]                   NVARCHAR (255)   NULL,
    [productCodeOLD]                NVARCHAR (20)    NULL,
    [productIndex]                  VARCHAR (50)     NULL,
    [productPrice]                  MONEY            NULL,
    [productQuantity]               INT              NULL,
    [gluonName]                     NVARCHAR (100)   NULL,
    [dateInput]                     DATETIME         NULL,
    [inStock]                       BIT              NULL,
    [delivered]                     BIT              NULL,
    [deliveredDate]                 DATETIME         NULL,
    [deliveryTrackingNumber]        NVARCHAR (50)    NULL,
    [status]                        VARCHAR (50)     NULL,
    [deletex]                       VARCHAR (50)     NULL,
    [OSID]                          INT              NULL,
    [NBPRINT]                       DATETIME         NULL,
    [productType]                   VARCHAR (50)     NULL,
    [switch_create]                 BIT              CONSTRAINT [DF__tblOrders__strea__633B3E47] DEFAULT ((0)) NOT NULL,
    [switch_createDate]             DATETIME         NULL,
    [stream]                        BIT              NULL,
    [streamPrintDate]               DATETIME         NULL,
    [groupID]                       INT              CONSTRAINT [DF_tblOrders_Products_groupID] DEFAULT ((0)) NULL,
    [created_on]                    DATETIME         CONSTRAINT [DF_tblOrders_Products_lastUpdate] DEFAULT (getdate()) NULL,
    [modified_on]                   DATETIME         CONSTRAINT [DF__tblOrders__modif__344DCC76] DEFAULT (getdate()) NULL,
    [fastTrak]                      BIT              CONSTRAINT [DF_tblOrders_Products_fastTrack] DEFAULT ((0)) NULL,
    [fastTrak_productType]          VARCHAR (50)     NULL,
    [fastTrak_newQTY]               NCHAR (10)       NULL,
    [fastTrak_resubmit]             BIT              CONSTRAINT [DF_tblOrders_Products_fastTrack_resubmitted] DEFAULT ((0)) NOT NULL,
    [fastTrak_reimage]              BIT              CONSTRAINT [DF_tblOrders_Products_fastTrak_reimage] DEFAULT ((0)) NOT NULL,
    [fastTrak_imageFile_exported]   BIT              CONSTRAINT [DF_tblOrders_Products_fastTrak_export] DEFAULT ((0)) NOT NULL,
    [fastTrak_imageFile_exportedOn] DATETIME         NULL,
    [fastTrak_preventImposition]    BIT              CONSTRAINT [DF_tblOrders_Products_fastTrak_availableForImposition] DEFAULT ((0)) NOT NULL,
    [fastTrak_preventLabel]         BIT              CONSTRAINT [DF_tblOrders_Products_fastTrak_availableForLabel] DEFAULT ((0)) NOT NULL,
    [fastTrak_preventTicket]        BIT              CONSTRAINT [DF_tblOrders_Products_fastTrak_preventTicket] DEFAULT ((0)) NOT NULL,
    [fastTrak_labelGeneratedOn]     DATETIME         NULL,
    [fastTrak_ticketGeneratedOn]    DATETIME         NULL,
    [fastTrak_imposed]              BIT              CONSTRAINT [DF_tblOrders_Products_fastTrak_imposed] DEFAULT ((0)) NOT NULL,
    [fastTrak_imposedOn]            DATETIME         NULL,
    [fastTrak_completed]            BIT              CONSTRAINT [DF_tblOrders_Products_fastTrack_processed] DEFAULT ((0)) NOT NULL,
    [fastTrak_completedOn]          DATETIME         NULL,
    [fastTrak_status]               VARCHAR (50)     CONSTRAINT [DF_tblOrders_Products_fastTrack_status] DEFAULT ('In House') NULL,
    [fastTrak_status_lastModified]  DATETIME         CONSTRAINT [DF_tblOrders_Products_fastTrack_status_lastModified] DEFAULT (getdate()) NULL,
    [fastTrak_shippingLabelOption1] BIT              CONSTRAINT [DF_tblOrders_Products_fastTrack_shippingLabelOption1] DEFAULT ((0)) NOT NULL,
    [fastTrak_shippingLabelOption2] BIT              CONSTRAINT [DF_tblOrders_Products_fastTrack_shippingLabelOption2] DEFAULT ((0)) NOT NULL,
    [fastTrak_shippingLabelOption3] BIT              CONSTRAINT [DF_tblOrders_Products_fastTrack_shippingLabelOption3] DEFAULT ((0)) NOT NULL,
    [fastTrak_imprintName]          NVARCHAR (MAX)   NULL,
    [proofVersion]                  INT              CONSTRAINT [DF_tblOrders_Products_proofVersion] DEFAULT ((0)) NULL,
    [processType]                   VARCHAR (50)     NULL,
    [pnp_create]                    BIT              CONSTRAINT [DF_tblOrders_Products_pnp_create] DEFAULT ((0)) NOT NULL,
    [pnp_createDate]                DATETIME         NULL,
    [switchMerge_create]            INT              CONSTRAINT [DF_tblOrders_Products_switchMerge_create] DEFAULT ((0)) NULL,
    [NOP_productCode_ALT]           NVARCHAR (50)    NULL,
    [CustomerEmail]                 VARCHAR (255)    NULL,
    [AgentName]                     VARCHAR (255)    NULL,
    [isValidated]                   BIT              CONSTRAINT [DF_tblOrders_Products_isValidated] DEFAULT ((0)) NULL,
    [GbsCompanyId]                  VARCHAR (20)     NULL,
    [isPrinted]                     BIT              CONSTRAINT [DF_tblOrders_Products_isPrinted] DEFAULT ((0)) NULL,
    [productCode]                   VARCHAR (255)    NULL,
    [ordersProductsGUID]            UNIQUEIDENTIFIER CONSTRAINT [DF__tblOrders__order__3F979EC3] DEFAULT (newid()) NULL,
    [workFlowID]                    INT              NULL,
    CONSTRAINT [PK_tblOrders_Products_1] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);




GO

GO
CREATE NONCLUSTERED INDEX [IX_created_processType_productCode] ON [dbo].[tblOrders_Products] ([created_on], [processType], [productCode]) INCLUDE ([ID], [orderID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_deleteX] ON [dbo].[tblOrders_Products] ([deletex]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_deletex_INC_orderID_modified_on] ON [dbo].[tblOrders_Products] ([deletex]) INCLUDE ([orderID], [modified_on]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_deletex_INC_productID_modifiedon] ON [dbo].[tblOrders_Products] ([deletex]) INCLUDE ([productID], [modified_on]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Order_Products_DeleteX] ON [dbo].[tblOrders_Products] ([deletex], [groupID]) INCLUDE ([productCodeOLD]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Deletex_processtype_IncOrderID] ON [dbo].[tblOrders_Products] ([deletex], [processType]) INCLUDE ([orderID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_Products_deletex_FastTrakStatus] ON [dbo].[tblOrders_Products] ([deletex], [processType], [fastTrak_status]) INCLUDE ([ID], [orderID], [productCodeOLD], [productQuantity], [fastTrak_imprintName], [fastTrak_status_lastModified], [created_on]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_Products_deletex] ON [dbo].[tblOrders_Products] ([deletex], [productID]) INCLUDE ([ID], [orderID], [productCodeOLD]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fasttrack_Inc_ID_productID] ON [dbo].[tblOrders_Products] ([fastTrak]) INCLUDE ([ID], [productID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrak_fastTrakCompleted_deletex_fastTrackstatus_INC_ID_orderID_fastTrakimprintName] ON [dbo].[tblOrders_Products] ([fastTrak], [fastTrak_completed], [deletex], [fastTrak_status]) INCLUDE ([ID], [orderID], [fastTrak_imprintName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OrdersProducts_fastTrak_FTCompleted_FTCompletedOn] ON [dbo].[tblOrders_Products] ([fastTrak], [fastTrak_completed], [fastTrak_completedOn]) INCLUDE ([deletex]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrak_fastTrackProductType_fastTrackcompleted_INC_ID_orderID_fastTrackstatus] ON [dbo].[tblOrders_Products] ([fastTrak], [fastTrak_productType], [fastTrak_completed]) INCLUDE ([ID], [orderID], [fastTrak_status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrak_fastTrackstatus_INC_ID_orderID_fastTrakstatuslastModified] ON [dbo].[tblOrders_Products] ([fastTrak], [fastTrak_status]) INCLUDE ([ID], [orderID], [fastTrak_status_lastModified]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FT_completed] ON [dbo].[tblOrders_Products] ([fastTrak_completed]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrak_completed_processType_INC_orderID_fastTrak_completedOn] ON [dbo].[tblOrders_Products] ([fastTrak_completed], [processType]) INCLUDE ([orderID], [fastTrak_completedOn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FastTrack_Status] ON [dbo].[tblOrders_Products] ([fastTrak_status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_fastTrak_status_processType_INC_orderID_productID_productCode] ON [dbo].[tblOrders_Products] ([fastTrak_status], [processType]) INCLUDE ([orderID], [productID], [productCodeOLD]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_Products_GbsCompanyId] ON [dbo].[tblOrders_Products] ([GbsCompanyId]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_GBSCompanyID_INC_orderID_ID] ON [dbo].[tblOrders_Products] ([GbsCompanyId]) INCLUDE ([orderID], [ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblOrders_Products_groupID] ON [dbo].[tblOrders_Products] ([groupID]) INCLUDE ([productCodeOLD], [deletex]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [CD_IX] ON [dbo].[tblOrders_Products] ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [[IX_IsPrinted_ProcessType_Deletex_INC_productName_FTStatus_productCode]]] ON [dbo].[tblOrders_Products] ([isPrinted], [processType], [deletex]) INCLUDE ([productName], [fastTrak_status], [productCode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_modifiedon_INC_productID_deletex] ON [dbo].[tblOrders_Products] ([modified_on]) INCLUDE ([productID], [deletex]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AB_IX] ON [dbo].[tblOrders_Products] ([orderID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OPIDGUID] ON [dbo].[tblOrders_Products] ([ordersProductsGUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_processType] ON [dbo].[tblOrders_Products] ([processType]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_processType_INC_orderID_productCode] ON [dbo].[tblOrders_Products] ([processType]) INCLUDE ([orderID], [productCodeOLD], [productID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_processType_deletex_INC_ID_orderID] ON [dbo].[tblOrders_Products] ([processType], [deletex]) INCLUDE ([ID], [orderID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PC] ON [dbo].[tblOrders_Products] ([productCodeOLD]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_ProductCode_INC_CreatedOn] ON [dbo].[tblOrders_Products] ([productCodeOLD]) INCLUDE ([created_on]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productID_deletex] ON [dbo].[tblOrders_Products] ([productID], [deletex]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrders_Products_productID_deletex] ON [dbo].[tblOrders_Products] ([productID], [deletex]) INCLUDE ([orderID], [productQuantity]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_switch_create] ON [dbo].[tblOrders_Products] ([switch_create]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_switchcreate_Processtype_deletex_INC_many] ON [dbo].[tblOrders_Products] ([switch_create], [processType], [deletex]) INCLUDE ([orderID], [productID], [productName], [productQuantity], [groupID], [modified_on], [productCode]) ON [PRIMARY]
GO
CREATE TRIGGER [dbo].[trg_update_tblOrders_Products] on [dbo].[tblOrders_Products] 
FOR UPDATE AS            
BEGIN
    UPDATE tblOrders_Products
    SET modified_on=getdate()
    FROM tblOrders_Products INNER JOIN deleted d
    on tblOrders_Products.[id] = d.[id]

	insert into dbo.tblEntityStatus (EntityId,EntityName,StatusType,[Status],StatusDate)
	select op.Id,'Orders_Products','Order Product Status',op.fastTrak_status,getdate()
	from dbo.tblOrders_Products op
	inner join deleted d
		on op.Id = d.Id
	where op.fastTrak_status <> d.fastTrak_status

	-- add to entity log
	DECLARE  @LogID TABLE (LogID BIGINT, EntityID int, CreatedOn datetime);

	INSERT INTO tblEntityLog (EntityID,EntityTypeID,LogTypeID,LogDateTime,CreatedBy)
	OUTPUT inserted.LogID, inserted.EntityID, inserted.CreatedOn INTO @LogID
	SELECT d.ID, (SELECT EntityTypeID FROM tblEntityType WHERE EntityType = 'OPID'), (SELECT LogTypeID FROM tblEntityLogType WHERE LogType = 'Status Change'), getdate(),suser_sname()
	from dbo.tblOrders_Products op
	inner join deleted d
		on op.Id = d.Id
	where op.fastTrak_status <> d.fastTrak_status
		
	INSERT INTO tblEntityLogInfo (LogID, LogInfo, CreatedBy, CreatedOn)
	SELECT LogID, i.fastTrak_Status, suser_sname(), CreatedOn
	FROM @LogID l
	INNER JOIN inserted i on l.EntityID = i.ID

END
GO


