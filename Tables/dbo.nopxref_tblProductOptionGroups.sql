CREATE TABLE [dbo].[nopxref_tblProductOptionGroups]
(
[optionGroupId] [int] NOT NULL IDENTITY(1000, 1),
[optionGroupCaption] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[optionGroupType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isEditable] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptionGroups_isEditable] DEFAULT ((1)),
[isActive] [bit] NULL CONSTRAINT [DF_nopxref_tblProductOptionGroups_isActive] DEFAULT ((1)),
[nopProductAttributeId] [int] NULL,
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_nopxref_tblProductOptionGroups_dateCreated] DEFAULT (getdate()),
[dateUpdated] [datetime] NOT NULL CONSTRAINT [DF_nopxref_tblProductOptionGroups_dateUpdated] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[nopxref_tblProductOptionGroups] ADD CONSTRAINT [PK_nopxref_tblProductOptionGroups] PRIMARY KEY CLUSTERED  ([optionGroupId]) WITH (FILLFACTOR=90) ON [PRIMARY]