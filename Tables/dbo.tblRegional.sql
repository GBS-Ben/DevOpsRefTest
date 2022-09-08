﻿CREATE TABLE [dbo].[tblRegional]
(
[regionalID] [int] NOT NULL IDENTITY(1, 1),
[nationalID] [int] NULL,
[company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [bigint] NULL,
[fax] [bigint] NULL,
[numAgents] [int] NULL,
[numOffices] [int] NULL,
[website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_phone] [bigint] NULL,
[mgr1_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr1_fax] [bigint] NULL,
[mgr2_contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_phone] [bigint] NULL,
[mgr2_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr2_fax] [bigint] NULL,
[mgr3_contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_phone] [bigint] NULL,
[mgr3_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_website] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mgr3_fax] [bigint] NULL
) ON [PRIMARY]