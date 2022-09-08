CREATE TABLE [dbo].[GenericAttribute_LOCALJFJTEST]
(
[Id] [int] NOT NULL,
[EntityId] [int] NOT NULL,
[KeyGroup] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Key] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StoreId] [int] NOT NULL
) ON [PRIMARY]