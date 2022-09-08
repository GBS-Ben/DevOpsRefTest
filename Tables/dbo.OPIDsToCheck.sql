CREATE TABLE [dbo].[OPIDsToCheck]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[OPID] [int] NULL,
[JSONtoCheck] [varchar] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]