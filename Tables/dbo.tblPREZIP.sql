CREATE TABLE [dbo].[tblPREZIP]
(
[preZIP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[value05] [smallmoney] NULL,
[number05] [int] NULL,
[value06] [smallmoney] NULL,
[number06] [int] NULL,
[value07] [smallmoney] NULL,
[number07] [int] NULL,
[value08] [smallmoney] NULL,
[number08] [int] NULL,
[value09] [smallmoney] NULL,
[number09] [int] NULL,
[valueTOTAL] [smallmoney] NULL,
[numberTOTAL] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [123] ON [dbo].[tblPREZIP] ([preZIP]) WITH (FILLFACTOR=90) ON [PRIMARY]