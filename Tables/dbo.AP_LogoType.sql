CREATE TABLE [dbo].[AP_LogoType]
(
[ID] [int] NOT NULL,
[Sku_Pattern] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Product_Style] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Category] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Decoration] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Logo_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETLLoadDate] [datetime] NULL,
[ETLHistoryID] [int] NULL,
[TheHashKey] [varbinary] (256) NULL
) ON [PRIMARY]
GO
