CREATE TABLE [dbo].[tempNC]
(
[PKID] [decimal] (18, 0) NOT NULL,
[orderNo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPID] [decimal] (18, 0) NOT NULL,
[surface1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[surface2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[surface3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ticketName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]