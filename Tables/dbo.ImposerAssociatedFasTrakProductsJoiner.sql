CREATE TABLE [dbo].[ImposerAssociatedFasTrakProductsJoiner]
(
[ImposerOPID] [int] NULL,
[AssociatedOPID] [int] NULL,
[ProductCodePrefix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComboOPID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]