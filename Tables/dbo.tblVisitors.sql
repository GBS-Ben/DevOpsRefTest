CREATE TABLE [dbo].[tblVisitors]
(
[visitorID] [int] NOT NULL IDENTITY(1, 1),
[sessionID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customerID] [int] NULL,
[visitorIP] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[visitorBrowser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[visitorDateTime] [datetime] NULL,
[referrer] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[entryPage] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[searchCount] [int] NULL,
[abandonedCart] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblVisitors] ADD CONSTRAINT [PK_tblVisitors] PRIMARY KEY CLUSTERED  ([visitorID]) WITH (FILLFACTOR=90) ON [PRIMARY]