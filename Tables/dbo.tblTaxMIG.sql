CREATE TABLE [dbo].[tblTaxMIG]
(
[orders_total_id] [int] NULL,
[orders_id] [int] NOT NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[value] [money] NOT NULL,
[class] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sort_order] [int] NOT NULL
) ON [PRIMARY]