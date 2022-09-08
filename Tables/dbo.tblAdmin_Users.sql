CREATE TABLE [dbo].[tblAdmin_Users]
(
[userID] [int] NOT NULL IDENTITY(1, 1),
[firstName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userPassword] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userEmail] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[imagePath] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[storeSetup] [bit] NOT NULL,
[checkoutSetup] [bit] NOT NULL,
[adminSecurity] [bit] NOT NULL,
[products] [bit] NOT NULL,
[categories] [bit] NOT NULL,
[orders] [bit] NOT NULL,
[customers] [bit] NOT NULL,
[reports] [bit] NOT NULL,
[downloads] [bit] NOT NULL,
[vouchers] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAdmin_Users] ADD CONSTRAINT [PK_tblAdmin_Users] PRIMARY KEY CLUSTERED  ([userID]) WITH (FILLFACTOR=90) ON [PRIMARY]