CREATE TABLE [dbo].[tblSuppliers]
(
[supplierID] [int] NOT NULL IDENTITY(1, 1),
[companyName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suburb] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[postCode] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[website] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactEmail] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactPhone] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactMobile] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactFax] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSuppliers] ADD CONSTRAINT [PK_tblSuppliers] PRIMARY KEY CLUSTERED  ([supplierID]) WITH (FILLFACTOR=90) ON [PRIMARY]