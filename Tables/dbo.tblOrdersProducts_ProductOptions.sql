CREATE TABLE [dbo].[tblOrdersProducts_ProductOptions] (
    [PKID]               INT              IDENTITY (9000000, 1) NOT NULL,
    [PKID_Remote]        INT              NULL,
    [ordersProductsID]   INT              NULL,
    [optionID]           INT              NULL,
    [optionCaption]      NVARCHAR (255)   NULL,
    [optionPrice]        MONEY            NULL,
    [optionGroupCaption] NVARCHAR (50)    NULL,
    [textValue]          NVARCHAR (4000)  NULL,
    [deletex]            VARCHAR (50)     NULL,
    [optionQty]          INT              CONSTRAINT [DF_tblOrdersProducts_ProductOptions_optionQTY_1] DEFAULT ((1)) NOT NULL,
    [created_on]         DATETIME         CONSTRAINT [DF__tblOrders__creat__0C0AD0F2_1] DEFAULT (getdate()) NULL,
    [modified_on]        DATETIME         CONSTRAINT [DF__tblOrders__modif__0CFEF52B_1] DEFAULT (getdate()) NULL,
    [ordersProductsGUID] UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_tblOrdersProducts_ProductOptions_1] PRIMARY KEY NONCLUSTERED ([PKID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_tblOrdersProducts_ProductOptions_tblOrders_Products_2] FOREIGN KEY ([ordersProductsID]) REFERENCES [dbo].[tblOrders_Products] ([ID])
);


GO
ALTER TABLE [dbo].[tblOrdersProducts_ProductOptions] NOCHECK CONSTRAINT [FK_tblOrdersProducts_ProductOptions_tblOrders_Products_2];




GO

GO

GO
CREATE NONCLUSTERED INDEX [NCI_CreatedOn] ON [dbo].[tblOrdersProducts_ProductOptions] ([created_on]) INCLUDE ([ordersProductsID], [deletex]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>] ON [dbo].[tblOrdersProducts_ProductOptions] ([deletex]) INCLUDE ([ordersProductsID], [optionID], [optionCaption], [textValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_deletex_inc_textValue_ordersProductsID] ON [dbo].[tblOrdersProducts_ProductOptions] ([deletex]) INCLUDE ([textValue], [ordersProductsID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrdersProducts_ProductOptions_deletex_created_on] ON [dbo].[tblOrdersProducts_ProductOptions] ([deletex], [created_on]) INCLUDE ([ordersProductsID], [optionCaption], [textValue]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OptionCaption_Deletex_IncOrdersProductsID] ON [dbo].[tblOrdersProducts_ProductOptions] ([optionCaption], [deletex]) INCLUDE ([ordersProductsID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrdersProducts_ProductOptions_optionCaption_deletex] ON [dbo].[tblOrdersProducts_ProductOptions] ([optionCaption], [deletex]) INCLUDE ([ordersProductsID], [optionID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_optionCaption_deletex_INC_ordersProductsID_textValue] ON [dbo].[tblOrdersProducts_ProductOptions] ([optionCaption], [deletex]) INCLUDE ([ordersProductsID], [textValue]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrdersProducts_ProductOptions_ODC]
    ON [dbo].[tblOrdersProducts_ProductOptions]([optionCaption] ASC, [deletex] ASC, [created_on] ASC)
    INCLUDE([ordersProductsID]);




GO
CREATE NONCLUSTERED INDEX [IX_OptionID_IncludePKIDTextValue] ON [dbo].[tblOrdersProducts_ProductOptions] ([optionID]) INCLUDE ([PKID], [textValue]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_optionID_deletex_inc_ordersProductsID_textValue] ON [dbo].[tblOrdersProducts_ProductOptions] ([optionID], [deletex]) INCLUDE ([ordersProductsID], [textValue]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOrdersProducts_ProductOptions_optionID_optionCaption_optionGroupCaption] ON [dbo].[tblOrdersProducts_ProductOptions] ([optionID], [optionCaption], [optionGroupCaption]) INCLUDE ([created_on]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OPIDGUID] ON [dbo].[tblOrdersProducts_ProductOptions] ([ordersProductsGUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OP] ON [dbo].[tblOrdersProducts_ProductOptions] ([ordersProductsID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OPPO_OrdersProductsID_Deletex_INC_optionCaption] ON [dbo].[tblOrdersProducts_ProductOptions] ([ordersProductsID], [deletex]) INCLUDE ([optionCaption], [optionID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OPPO_OrdersProductsID_Deletex_INC_optionCaption_textvalue] ON [dbo].[tblOrdersProducts_ProductOptions] ([ordersProductsID], [deletex], [optionID]) INCLUDE ([optionCaption], [textValue], [optionPrice], [optionGroupCaption]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_PKID] ON [dbo].[tblOrdersProducts_ProductOptions] ([PKID]) WITH (FILLFACTOR=90) ON [PRIMARY]