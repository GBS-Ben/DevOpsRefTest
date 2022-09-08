CREATE TABLE [dbo].[tblNBS_DD_OV]
(
[sortNo] [int] NOT NULL IDENTITY(1, 1),
[contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[title] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bkgnd] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sht] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pos] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COlogo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtextAll] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COtext2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RO] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sortNo_seed] [int] NULL
) ON [PRIMARY]