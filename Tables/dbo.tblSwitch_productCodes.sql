CREATE TABLE [dbo].[tblSwitch_productCodes]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[productCode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSwitch_productCodes] ADD CONSTRAINT [PK_tblSwitch_productCodes] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PC] ON [dbo].[tblSwitch_productCodes] ([productCode]) ON [PRIMARY]