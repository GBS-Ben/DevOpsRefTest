CREATE TABLE [dbo].[nopxref_tblProductOptions]
(
[optionId] [int] NOT NULL IDENTITY(10000, 1),
[optionGroupId] [int] NULL,
[optionCaption] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnOrderView] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptions_displayOnOrderView] DEFAULT ((1)),
[orderViewDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnJobTicket] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptions_displayOnJobTicket] DEFAULT ((1)),
[jobTicketDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnReceipt] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptions_displayOnReceipt] DEFAULT ((1)),
[receiptDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isFileOppo] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptions_isFileOppo] DEFAULT ((0)),
[isHyperlink] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptions_isHyperlink] DEFAULT ((0)),
[isEditable] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptions_isEditable] DEFAULT ((1)),
[isActive] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptions_isActive] DEFAULT ((1)),
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_nopxref_tblProductOptions_dateCreated] DEFAULT (getdate()),
[dateUpdated] [datetime] NOT NULL CONSTRAINT [DF_nopxref_tblProductOptions_dateUpdated] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[nopxref_tblProductOptions] ADD CONSTRAINT [PK_nopxref_tblProductOptions] PRIMARY KEY CLUSTERED  ([optionId]) WITH (FILLFACTOR=90) ON [PRIMARY]