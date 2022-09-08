CREATE TABLE [dbo].[nopxref_tblProduct_ProductOptions]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[productId] [int] NOT NULL,
[optionId] [int] NOT NULL,
[optionGroupId] [int] NOT NULL,
[optionPrice] [money] NULL,
[optionDiscountApplies] [bit] NOT NULL CONSTRAINT [DF_nopxref_tblProduct_ProductOptions_optionDiscountApplies] DEFAULT ((1)),
[displayOnOrderView] [bit] NOT NULL CONSTRAINT [DF_nopxref_tblProduct_ProductOptions_displayOnOrderView] DEFAULT ((1)),
[orderViewDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnJobTicket] [bit] NOT NULL CONSTRAINT [DF_nopxref_tblProduct_ProductOptions_displayOnJobTicket] DEFAULT ((1)),
[jobTicketDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnReceipt] [bit] NOT NULL CONSTRAINT [DF_nopxref_tblProduct_ProductOptions_displayOnReceipt] DEFAULT ((1)),
[receiptDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isEditable] [bit] NOT NULL CONSTRAINT [DF_nopxref_tblProduct_ProductOptions_isEditable] DEFAULT ((1)),
[isActive] [bit] NOT NULL CONSTRAINT [DF_nopxref_tblProduct_ProductOptions_isActive] DEFAULT ((1)),
[nopProduct_ProductAttributeId] [int] NULL,
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_nopxref_tblProduct_ProductOptions_dateCreated] DEFAULT (getdate()),
[dateModified] [datetime] NOT NULL CONSTRAINT [DF_tblProduct_ProductOptions_nopxref_dateModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[nopxref_tblProduct_ProductOptions] ADD CONSTRAINT [PK_nopxref_tblProduct_ProductOptions] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_nopxref_tblProduct_ProductOptions_productId_optionId] ON [dbo].[nopxref_tblProduct_ProductOptions] ([productId], [optionId], [isActive]) ON [PRIMARY]