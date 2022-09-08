CREATE TABLE [dbo].[ShippingLabelReport]
(
[reportId] [int] NOT NULL IDENTITY(1, 1),
[flowName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reportName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[parameters] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ShippingLabelReport] ADD CONSTRAINT [PK_tblShippingLabelReport] PRIMARY KEY CLUSTERED  ([reportId]) ON [PRIMARY]