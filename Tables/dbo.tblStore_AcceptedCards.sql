CREATE TABLE [dbo].[tblStore_AcceptedCards]
(
[cardID] [int] NOT NULL IDENTITY(1, 1),
[cardName] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardLogo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cardOnline] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblStore_AcceptedCards] ADD CONSTRAINT [PK_tblStore_AcceptedCards] PRIMARY KEY CLUSTERED  ([cardID]) WITH (FILLFACTOR=90) ON [PRIMARY]