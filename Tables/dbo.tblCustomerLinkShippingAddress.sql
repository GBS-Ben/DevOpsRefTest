CREATE TABLE [dbo].[tblCustomerLinkShippingAddress]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nickname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[defaultAddress] [int] NULL
) ON [PRIMARY]