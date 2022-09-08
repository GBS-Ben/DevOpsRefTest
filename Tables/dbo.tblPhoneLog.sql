﻿CREATE TABLE [dbo].[tblPhoneLog]
(
[pkid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inOUT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ext] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[employee] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trunk] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dialedDigits] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[path] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startTime] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[elapsedTime] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[calctimeSeconds] [int] NULL,
[calctimeMinutes] [int] NULL,
[calctimeTotal] [decimal] (12, 2) NULL,
[avgMin] [decimal] (12, 2) NULL,
[cost] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acct] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[logDate] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dailyNumberIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dailyNumberOUT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dailyAVGIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dailyAVGOUT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalNumberALL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalAVGALL] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dayoftheWeek] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalINTIME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalOUTTIME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[totalALLTIME] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]