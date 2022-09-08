CREATE TABLE [dbo].[ImposerCavityIteration]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[OrderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OPID] [int] NULL,
[Surface1] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface2] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Surface3] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutputName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProductQuantity] [int] NULL,
[Resubmit] [bit] NULL,
[Expedite] [bit] NULL
) ON [PRIMARY]