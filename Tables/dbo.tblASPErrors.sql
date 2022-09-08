CREATE TABLE [dbo].[tblASPErrors]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[sessionID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[category] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorNum] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorSource] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorFile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorLine] [int] NULL,
[ASPErrorColumn] [int] NULL,
[ASPErrorDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ASPErrorFullDesc] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logDate] [datetime] NULL
) ON [PRIMARY]