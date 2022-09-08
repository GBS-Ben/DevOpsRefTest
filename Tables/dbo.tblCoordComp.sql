CREATE TABLE [dbo].[tblCoordComp]
(
[coord_ID] [int] NOT NULL,
[firstName_Coord] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastName_Coord] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[email_Coord] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Company] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[address] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[city] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zip] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]