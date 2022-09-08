CREATE TABLE [dbo].[formattedBulkMailDBList1]
(
[customerID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frontFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[backFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IMBarcode] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[endorsementLine] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trayNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jobNumber] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]