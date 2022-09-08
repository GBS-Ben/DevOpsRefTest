CREATE TABLE [dbo].[tblCustomers_Password]
(
[customerID] [int] NULL,
[firstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[surName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suburb] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postCode] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mobilePhone] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[website] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerPassword] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[newsletter] [bit] NOT NULL,
[membershipType] [int] NULL,
[membershipNo] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[login] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]