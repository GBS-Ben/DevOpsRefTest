CREATE TABLE [dbo].[tblProductOptionGroups]
(
[optionGroupID] [int] NOT NULL IDENTITY(1, 1),
[optionGroupCaption] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionGroupType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblProductOptionGroups] ADD CONSTRAINT [PK_tblProductOptionGroups] PRIMARY KEY CLUSTERED  ([optionGroupID]) WITH (FILLFACTOR=90) ON [PRIMARY]