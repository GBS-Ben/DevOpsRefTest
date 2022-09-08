CREATE TABLE [dbo].[tblCustomersGroup]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]