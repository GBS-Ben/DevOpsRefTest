CREATE TABLE [dbo].[tblRatings]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[orderID] [int] NULL CONSTRAINT [DF_tblRatings_orderID] DEFAULT ((0)),
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productID] [int] NULL CONSTRAINT [DF_tblRatings_productID] DEFAULT ((0)),
[rating] [int] NULL,
[comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRatings] ADD CONSTRAINT [PK_tblRatings] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]