CREATE TABLE [dbo].[tblAMZ_orderValid]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[PKID] [nvarchar] (511) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order-id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order-item-id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase-date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payments-date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reporting-date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[promise-date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[days-past-promise] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer-email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer-name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[buyer-phone-number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sku] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product-name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity-purchased] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity-shipped] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity-to-ship] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item-price] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item-tax] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping-price] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping-tax] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-service-level] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[recipient-name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-address-1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-address-2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-address-3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-postal-code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-phone-number] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax-location-code] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax-location-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax-location-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tax-location-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-taxable-district] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-taxable-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-taxable-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-taxable-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-non-taxable-district] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-non-taxable-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-non-taxable-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-non-taxable-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-zero-rated-district] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-zero-rated-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-zero-rated-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-zero-rated-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-tax-collected-district] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-tax-collected-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-tax-collected-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-item-tax-collected-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-taxable-district] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-taxable-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-taxable-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-taxable-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-non-taxable-district] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-non-taxable-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-non-taxable-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-non-taxable-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-zero-rated-district] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-zero-rated-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-zero-rated-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-zero-rated-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-tax-collected-district] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-tax-collected-city] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-tax-collected-county] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[per-unit-shipping-tax-collected-state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item-promotion-discount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item-promotion-id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-promotion-discount] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-promotion-id] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery-start-date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery-end-date] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery-time-zone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery-Instructions] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales-channel] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderStatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[migStatus] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[modified_on] [datetime] NULL,
[lastStatusUpdate] [datetime] NULL,
[weightOz] [int] NULL,
[fasTrak_resubmit] [bit] NOT NULL CONSTRAINT [DF_tblAMZ_orderValid_fasTrak_resubmit] DEFAULT ((0)),
[fasTrak_newQTY] [int] NULL,
[created_on] [datetime] NOT NULL CONSTRAINT [DF_tblAMZ_orderValid_created_on] DEFAULT (getdate()),
[switch_create] [bit] NOT NULL CONSTRAINT [df0] DEFAULT ((0)),
[switch_createDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAMZ_orderValid] ADD CONSTRAINT [IX_P] PRIMARY KEY NONCLUSTERED ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_created_on_INC_productName] ON [dbo].[tblAMZ_orderValid] ([created_on]) INCLUDE ([product-name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderID] ON [dbo].[tblAMZ_orderValid] ([order-id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblAMZ_orderValid] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_PKID] ON [dbo].[tblAMZ_orderValid] ([PKID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PDate] ON [dbo].[tblAMZ_orderValid] ([purchase-date]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_shipServiceLevel_inc_orderNo_productName_QTYpurchased] ON [dbo].[tblAMZ_orderValid] ([ship-service-level]) INCLUDE ([orderNo], [product-name], [quantity-purchased]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblAMZ_orderValid_ship-service-level] ON [dbo].[tblAMZ_orderValid] ([ship-service-level]) INCLUDE ([orderNo], [sku], [product-name]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblAMZ_orderValid_ship-service-level_product_sku] ON [dbo].[tblAMZ_orderValid] ([ship-service-level], [product-name], [sku]) INCLUDE ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_sku] ON [dbo].[tblAMZ_orderValid] ([sku]) INCLUDE ([orderNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_weightOz_INC_PKID_product-name_quantity-purchased] ON [dbo].[tblAMZ_orderValid] ([weightOz]) INCLUDE ([PKID], [product-name], [quantity-purchased]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE TRIGGER [dbo].[trg_update_tblAMZ_orderValid] on [dbo].[tblAMZ_orderValid] 
FOR UPDATE AS            
BEGIN
    UPDATE tblAMZ_orderValid
    SET modified_on=getDate()
    FROM tblAMZ_orderValid INNER JOIN deleted d
    ON tblAMZ_orderValid.[order-ID] = d.[order-ID]

    UPDATE tblAMZ_orderValid
    SET lastStatusUpdate=getDate()
    FROM deleted
    WHERE 
	tblAMZ_orderValid.[order-ID] = deleted.[order-ID] AND tblAMZ_orderValid.orderStatus <> deleted.orderStatus
	OR
	tblAMZ_orderValid.[order-ID] = deleted.[order-ID] AND deleted.orderStatus IS NULL


END