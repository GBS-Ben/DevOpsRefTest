CREATE TABLE [dbo].[tblSkuGroupGate]
(
[skuGroup] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Include] [bit] NULL CONSTRAINT [DF_tblSkuGroupGate_Include] DEFAULT ((0)),
[gtgOverride] [bit] NULL CONSTRAINT [DF_tblSkuGroupGate_gtgOverride] DEFAULT ((0)),
[shipNowOverride] [bit] NULL CONSTRAINT [DF_tblSkuGroupGate_shipNowOverride] DEFAULT ((0))
) ON [PRIMARY]