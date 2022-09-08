CREATE TABLE [dbo].[tempJF_2019AMZorders]
(
[parentASIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[childASIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalOrderedUnits] [int] NULL,
[totalSold] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalOrderItems] [int] NULL
) ON [PRIMARY]