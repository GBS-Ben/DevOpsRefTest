﻿CREATE TABLE [dbo].[tblEntries_1Time]
(
[entryPerson_firstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPerson_lastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPerson_address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPerson_city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPerson_state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPerson_zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPerson_phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPerson_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[q1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[q2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[insertDate] [datetime] NULL,
[entryFormID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[orderStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderTotal] [money] NULL,
[firstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]