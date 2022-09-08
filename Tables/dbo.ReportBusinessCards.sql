CREATE TABLE [dbo].[ReportBusinessCards]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[orderDate] [datetime] NULL,
[orderMonth] [int] NULL,
[orderYear] [int] NULL,
[productCode] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productQuantity] [int] NULL,
[option_RoundedCorners] [bit] NOT NULL CONSTRAINT [DF_ReportBusinessCards_Option_RoundedCorners] DEFAULT ((0)),
[optionTotal_RoundedCorners] [money] NULL,
[option_DoubleThick32pt] [bit] NOT NULL CONSTRAINT [DF_ReportBusinessCards_Option_DoubleThick] DEFAULT ((0)),
[optionTotal_DoubleThick32pt] [money] NULL,
[option_LuxeColorFill42pt] [bit] NOT NULL CONSTRAINT [DF_ReportBusinessCards_Option_LuxeColorFill42pt] DEFAULT ((0)),
[optionTotal_LuxeColorFill42pt] [money] NULL,
[option_SoftTouch] [bit] NOT NULL CONSTRAINT [DF_ReportBusinessCards_Option_SoftTouch] DEFAULT ((0)),
[optionTotal_SoftTouch] [money] NULL,
[opidTotal] [money] NULL,
[oppoTotal] [money] NULL,
[opid_oppo_combinedTotal] [money] NULL,
[orderTotal] [money] NULL,
[OPID] [int] NULL
) ON [PRIMARY]