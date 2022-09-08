CREATE TABLE [dbo].[ReportMarkfulDashboard]
(
[measurable] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frequency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[moneyValue] [money] NULL CONSTRAINT [DF_ReportMarkfulDashboard_moneyValue] DEFAULT ((0)),
[intValue] [int] NULL CONSTRAINT [DF_ReportMarkfulDashboard_intValue] DEFAULT ((0)),
[runDate] [datetime] NULL
) ON [PRIMARY]