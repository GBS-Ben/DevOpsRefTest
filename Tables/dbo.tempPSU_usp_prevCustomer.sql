CREATE TABLE [dbo].[tempPSU_usp_prevCustomer]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[orderNo] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL
) ON [PRIMARY]