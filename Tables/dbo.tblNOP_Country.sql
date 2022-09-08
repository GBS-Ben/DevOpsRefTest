CREATE TABLE [dbo].[tblNOP_Country]
(
[Id] [int] NOT NULL,
[Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AllowsBilling] [bit] NOT NULL,
[AllowsShipping] [bit] NOT NULL,
[TwoLetterIsoCode] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThreeLetterIsoCode] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumericIsoCode] [int] NOT NULL,
[SubjectToVat] [bit] NOT NULL,
[Published] [bit] NOT NULL,
[DisplayOrder] [int] NOT NULL,
[LimitedToStores] [bit] NOT NULL
) ON [PRIMARY]