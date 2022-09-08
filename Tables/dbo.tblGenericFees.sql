CREATE TABLE [dbo].[tblGenericFees]
(
[feeID] [int] NOT NULL IDENTITY(1, 1),
[feeName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amount] [money] NULL,
[taxApplies] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGenericFees] ADD CONSTRAINT [PK_tblGenericFees] PRIMARY KEY CLUSTERED  ([feeID]) WITH (FILLFACTOR=90) ON [PRIMARY]