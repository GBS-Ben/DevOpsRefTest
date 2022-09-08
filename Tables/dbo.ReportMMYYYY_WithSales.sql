CREATE TABLE [dbo].[ReportMMYYYY_WithSales]
(
[PKID] [int] NOT NULL IDENTITY(1, 1),
[PC] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MM] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YYYY] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalOPIDSales] [money] NULL,
[TotalOPPXSales] [money] NULL,
[TotalSales] [money] NULL
) ON [PRIMARY]