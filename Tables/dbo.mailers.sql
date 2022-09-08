CREATE TABLE [dbo].[mailers]
(
[customerID] [int] NULL,
[frontFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[backFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prefix] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IMBarcode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[endorsementLine] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trayNumber] [int] NULL,
[jobNumber] [int] NULL,
[isDeleted] [int] NULL,
[importedOn] [datetime] NULL,
[id] [bigint] NOT NULL IDENTITY(1, 1),
[group_id] [int] NULL,
[sort] [int] NULL
) ON [PRIMARY]