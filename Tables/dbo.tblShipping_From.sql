CREATE TABLE [dbo].[tblShipping_From]
(
[storeID] [int] NULL,
[company] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tollFree] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSZ] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ixStoreID] ON [dbo].[tblShipping_From] ([storeID]) WITH (FILLFACTOR=90) ON [PRIMARY]