CREATE TABLE [dbo].[tblEntityType]
(
[EntityTypeId] [int] NOT NULL IDENTITY(1, 1),
[EntityType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblEntityType] ADD CONSTRAINT [PK_tblEntityType] PRIMARY KEY CLUSTERED ([EntityTypeId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EntityType] ON [dbo].[tblEntityType] ([EntityType]) ON [PRIMARY]