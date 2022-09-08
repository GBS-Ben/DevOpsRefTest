CREATE TABLE [dbo].[tblCarrier]
(
[carrierId] [int] NOT NULL,
[carrierName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shipEngineCarrierCode] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dateCreated] [datetime] NOT NULL,
[dateUpdated] [datetime] NOT NULL
) ON [PRIMARY]