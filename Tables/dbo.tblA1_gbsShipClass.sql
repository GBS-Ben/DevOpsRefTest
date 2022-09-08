CREATE TABLE [dbo].[tblA1_gbsShipClass]
(
[gbsShipClass] [int] NOT NULL IDENTITY(1, 1),
[carrier] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailClass] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mailPieceShape] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblA1_gbsShipClass] ADD CONSTRAINT [PK_tblA1_gbsShipClass] PRIMARY KEY CLUSTERED  ([gbsShipClass]) ON [PRIMARY]