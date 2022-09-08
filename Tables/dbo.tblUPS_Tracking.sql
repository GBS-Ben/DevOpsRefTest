CREATE TABLE [dbo].[tblUPS_Tracking]
(
[pkid] [int] NOT NULL,
[trackingnumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[voidindicator] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[jobnumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cod] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numberpackages] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[freight] [int] NULL,
[emailsent] [datetime] NULL,
[weight] [int] NULL
) ON [PRIMARY]