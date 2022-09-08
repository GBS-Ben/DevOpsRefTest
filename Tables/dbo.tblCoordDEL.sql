CREATE TABLE [dbo].[tblCoordDEL]
(
[DEL] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[coordinatorID] [int] NOT NULL,
[contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[firstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[officeID] [int] NOT NULL,
[company] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]