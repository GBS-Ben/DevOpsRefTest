CREATE TABLE [dbo].[SearchTemplates]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[Section] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SqlString] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateFrom] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateTo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TemplateName] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Stock] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Field] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Type] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Search] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Params] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToToday] [bit] NULL,
[Include] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SearchTemplates] ADD CONSTRAINT [PK_SearchTemplates] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]