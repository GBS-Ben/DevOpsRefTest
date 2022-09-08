CREATE TABLE [dbo].[tblCartSessions_Products]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[sessionID] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productID] [int] NULL,
[quantity] [int] NULL,
[optionID] [int] NULL,
[productPrice] [money] NULL,
[categoryID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCartSessions_Products] ADD CONSTRAINT [PK_tblCartSessions_Products] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]