CREATE TABLE [dbo].[tblNOP_stateProvince]
(
[Id] [int] NOT NULL,
[CountryId] [int] NOT NULL,
[Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Abbreviation] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Published] [bit] NOT NULL,
[DisplayOrder] [int] NOT NULL
) ON [PRIMARY]