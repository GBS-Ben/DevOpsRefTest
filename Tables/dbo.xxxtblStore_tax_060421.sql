CREATE TABLE [dbo].[xxxtblStore_tax_060421]
(
[taxID] [int] NOT NULL IDENTITY(1, 1),
[countryID] [int] NULL,
[stateID] [int] NULL,
[description] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate] [float] NULL
) ON [PRIMARY]