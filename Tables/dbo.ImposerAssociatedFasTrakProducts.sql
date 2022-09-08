CREATE TABLE [dbo].[ImposerAssociatedFasTrakProducts]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[OrderID] [int] NULL,
[AssociatedOPID] [int] NULL,
[ProductCodePrefix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]