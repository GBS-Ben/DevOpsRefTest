CREATE TABLE [dbo].[dashboard_pageList]
(
[PKID] [smallint] NOT NULL IDENTITY(1, 1),
[displayName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[storedProcedure] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[categoryID] [smallint] NULL,
[dataEditable] [bit] NOT NULL,
[hidden] [bit] NOT NULL,
[contentType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dashboard_pageList] ADD CONSTRAINT [FK_dashboardDataParentID] FOREIGN KEY ([categoryID]) REFERENCES [dbo].[dashboard_pageCategories] ([PKID])
GO
ALTER TABLE [dbo].[dashboard_pageList] ADD CONSTRAINT [PK__dashboar__5E02827241474D3F] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]