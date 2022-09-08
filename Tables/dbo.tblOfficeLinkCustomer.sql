CREATE TABLE [dbo].[tblOfficeLinkCustomer]
(
[pkid] [int] NOT NULL IDENTITY(1, 1),
[customerID] [int] NULL,
[officeID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOfficeLinkCustomer] ADD CONSTRAINT [IX_tblOfficeLinkCustomer] UNIQUE CLUSTERED  ([pkid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOfficeLinkCustomer_1] ON [dbo].[tblOfficeLinkCustomer] ([officeID]) WITH (FILLFACTOR=90) ON [PRIMARY]