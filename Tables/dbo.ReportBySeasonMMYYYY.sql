﻿CREATE TABLE [dbo].[ReportBySeasonMMYYYY]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[MM] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YYYY] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]