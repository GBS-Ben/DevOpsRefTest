CREATE TABLE [dbo].[Flags]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[FlagName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FlagStatus] [bit] NOT NULL CONSTRAINT [DF_Flags_FlagStatus] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Flags] ADD CONSTRAINT [PK_Flags] PRIMARY KEY CLUSTERED  ([PKID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NCI_Flags] ON [dbo].[Flags] ([FlagName]) INCLUDE ([FlagStatus]) ON [PRIMARY]