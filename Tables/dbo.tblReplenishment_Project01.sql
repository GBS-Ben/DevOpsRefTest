CREATE TABLE [dbo].[tblReplenishment_Project01]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL
) ON [PRIMARY]