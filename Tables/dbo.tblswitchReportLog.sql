CREATE TABLE [dbo].[tblswitchReportLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ordersProductsID] [int] NOT NULL,
[orderNo] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reportName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[printDate] [datetime] NOT NULL,
[data] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[header] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fullname] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[printValidation] [bit] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [C_INDEX_ID_OPID_TblSwitchReportLog] ON [dbo].[tblswitchReportLog] ([ID] DESC, [ordersProductsID] DESC) ON [PRIMARY]