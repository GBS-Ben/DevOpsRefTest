CREATE TABLE [dbo].[tblMembership]
(
[membershipID] [int] NOT NULL IDENTITY(1, 1),
[membershipType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[membershipDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[globalDiscountRate] [real] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMembership] ADD CONSTRAINT [PK_tblMembership] PRIMARY KEY CLUSTERED  ([membershipID]) WITH (FILLFACTOR=90) ON [PRIMARY]