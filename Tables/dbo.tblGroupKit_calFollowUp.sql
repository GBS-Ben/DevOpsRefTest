﻿CREATE TABLE [dbo].[tblGroupKit_calFollowUp]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[inputDate] [datetime] NULL,
[contactName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comments] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[team] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[formName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[poster] [int] NULL,
[flyers] [int] NULL,
[groupOrderForms] [int] NULL,
[insertSamples] [int] NULL,
[insertFlyers] [int] NULL,
[quickcardForm] [int] NULL,
[envelopeSamples] [int] NULL,
[calendarPadSamples] [int] NULL,
[quickstixSamples] [int] NULL,
[quickCardSamples] [int] NULL
) ON [PRIMARY]