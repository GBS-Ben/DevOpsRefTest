CREATE TABLE [dbo].[reportTestTable]
(
[PKID] [decimal] (18, 0) NOT NULL,
[orderNo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OPID] [decimal] (18, 0) NOT NULL,
[uvType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[qty] [decimal] (18, 0) NULL,
[shipType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]