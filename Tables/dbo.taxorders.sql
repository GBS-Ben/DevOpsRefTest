CREATE TABLE [dbo].[taxorders]
(
[orderno] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productTotal] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipTotal] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxTotal] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderTotal] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[paymentMethod] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]