﻿CREATE TABLE [dbo].[tblOffice]
(
[officeID] [int] NOT NULL IDENTITY(1, 1),
[regionalID] [int] NULL,
[company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nickname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address_old] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city_old] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state_old] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip_old] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddVerify] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[numAgents] [int] NULL,
[loc] [int] NULL,
[totalAgents] [int] NULL,
[website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rewards] [int] NULL,
[mgr1_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_fax] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JF_Retro] [int] NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumAgents2003] [int] NULL,
[NumAgents2004] [int] NULL,
[NumAgents2005] [int] NULL,
[NumAgents2006] [int] NULL,
[totalSales2003] [money] NULL,
[totalSales2004] [money] NULL,
[totalSales2005] [money] NULL,
[totalSales2006] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblOffice] ADD CONSTRAINT [IX_tblOffice] UNIQUE NONCLUSTERED  ([officeID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOffice_2] ON [dbo].[tblOffice] ([address_old]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblOffice_1] ON [dbo].[tblOffice] ([company]) WITH (FILLFACTOR=90) ON [PRIMARY]