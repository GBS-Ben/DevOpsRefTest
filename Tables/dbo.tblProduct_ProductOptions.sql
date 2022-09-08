CREATE TABLE [dbo].[tblProduct_ProductOptions]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[productID] [int] NOT NULL,
[optionID] [int] NOT NULL,
[optionGroupID] [int] NOT NULL,
[optionPrice] [money] NULL,
[optionDiscountApplies] [bit] NOT NULL,
[displayOnOrderView] [bit] NOT NULL CONSTRAINT [DF_tblProduct_ProductOptions_displayOnOrderView] DEFAULT ((1)),
[orderViewDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnJobTicket] [bit] NOT NULL CONSTRAINT [DF_tblProduct_ProductOptions_displayOnJobTicket] DEFAULT ((1)),
[jobTicketDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnReceipt] [bit] NOT NULL CONSTRAINT [DF_tblProduct_ProductOptions_displayOnReceipt] DEFAULT ((1)),
[receiptDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nopProduct_ProductAttributeId] [int] NULL,
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_tblProduct_ProductOptions_dateCreated] DEFAULT (getdate()),
[dateModified] [datetime] NOT NULL CONSTRAINT [DF_tblProduct_ProductOptions_dateModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProduct_ProductOptions] ADD CONSTRAINT [PK_tblProduct_ProductOptions] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_productID] ON [dbo].[tblProduct_ProductOptions] ([productID]) ON [PRIMARY]