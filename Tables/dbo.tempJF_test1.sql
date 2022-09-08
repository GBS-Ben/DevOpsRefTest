CREATE TABLE [dbo].[tempJF_test1]
(
[customer] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_tempJF_test1_customerGUID] DEFAULT (newid()),
[customerNo] [int] NULL
) ON [PRIMARY]