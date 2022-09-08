CREATE TABLE [dbo].[ReportSalesByProduct_Signs]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[Month] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Year] [int] NULL,
[productCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productQuantity] [int] NULL,
[option_2Grommets] [int] NOT NULL,
[option_2GrommetsTotal] [int] NOT NULL,
[option_4Grommets] [int] NOT NULL,
[option_4GrommetsTotal] [int] NOT NULL,
[option_AluminumReflectiveUpgrade] [int] NOT NULL,
[option_AluminumReflectiveUpgradeTotal] [int] NOT NULL,
[option_AluminumUpgrade] [int] NOT NULL,
[option_AluminumUpgradeTotal] [int] NOT NULL,
[option_PVCUpgrade] [int] NOT NULL,
[option_PVCUpgradeTotal] [int] NOT NULL,
[opidTotal] [money] NULL,
[oppoTotal] [int] NOT NULL,
[opid_oppo_combinedTotal] [money] NULL,
[OrderTotal] [money] NULL,
[OPID] [int] NOT NULL
) ON [PRIMARY]