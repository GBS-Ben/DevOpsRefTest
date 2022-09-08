CREATE TABLE [dbo].[ReportMCIDCounts]
(
[GBScompanyID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[aggOrderCount] [int] NULL CONSTRAINT [DF_ReportMCIDCounts_aggOrderCount] DEFAULT ((0)),
[aggOrderTotal] [money] NULL
) ON [PRIMARY]