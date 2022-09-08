CREATE TABLE [dbo].[tblPhoenixProducts]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[impositionGUID] [uniqueidentifier] NULL,
[layoutGUID] [uniqueidentifier] NULL,
[productGUID] [uniqueidentifier] NULL,
[insertDate] [datetime2] NOT NULL CONSTRAINT [DF_tblPhoenixProducts_insertDate] DEFAULT (getdate()),
[ordersProductsID] [nvarchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[index] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[color] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordered] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dieName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dieSource] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[diePath] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stock] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grade] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[grain] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[width] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[height] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[spacingType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rotation] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[templates] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[placed] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[total] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[overrun] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[properties] [nvarchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [CIndex_tblPhoenixProducts] ON [dbo].[tblPhoenixProducts] ([PKID], [impositionGUID], [productGUID]) ON [PRIMARY]