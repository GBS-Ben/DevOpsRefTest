CREATE TABLE [dbo].[tblProductOptions]
(
[optionID] [int] NOT NULL IDENTITY(1, 1),
[optionGroupID] [int] NULL,
[optionCaption] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnOrderView] [bit] NOT NULL CONSTRAINT [DF_tblProductOptions_displayOnOrderView] DEFAULT ((1)),
[orderViewDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnJobTicket] [bit] NOT NULL CONSTRAINT [DF_tblProductOptions_displayOnJobTicket] DEFAULT ((1)),
[jobTicketDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[displayOnReceipt] [bit] NOT NULL CONSTRAINT [DF_tblProductOptions_displayOnReceipt] DEFAULT ((1)),
[receiptDisplayText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isFileOppo] [bit] NOT NULL CONSTRAINT [DF_tblProductOptions_isFileOppo] DEFAULT ((0)),
[isHyperlink] [bit] NOT NULL CONSTRAINT [DF_tblProductOptions_isHyperlink] DEFAULT ((0)),
[nopProductAttributeId] [int] NULL,
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_tblProductOptions_dateCreated] DEFAULT (getdate()),
[dateUpdated] [datetime] NOT NULL CONSTRAINT [DF_tblProductOptions_dateUpdated] DEFAULT (getdate()),
[displayOnTicTic] [bit] NOT NULL CONSTRAINT [DF_tblProductOptions_displayOnTicTic] DEFAULT ((0)),
[TicTicText] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProductOptions] ADD CONSTRAINT [PK_tblProductOptions] PRIMARY KEY CLUSTERED  ([optionID]) WITH (FILLFACTOR=90) ON [PRIMARY]
