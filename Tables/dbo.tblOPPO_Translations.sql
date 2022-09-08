CREATE TABLE [dbo].[tblOPPO_Translations]
(
[producttype] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[legacyOptionID] [int] NULL,
[legacyOptionCaption] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[legacyTextValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[newOptionID] [int] NULL,
[newOptionCaption] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[newTextValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]