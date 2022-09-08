CREATE TABLE [dbo].[TempInfoBlockData]
(
[ordersProductsID] [int] NULL,
[Key] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TextValue] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NOT NULL,
[UpdatedOn] [datetime] NOT NULL
) ON [PRIMARY]