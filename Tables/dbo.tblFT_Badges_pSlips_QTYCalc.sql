CREATE TABLE [dbo].[tblFT_Badges_pSlips_QTYCalc]
(
[OPID] [int] NULL,
[orderNo] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[originalQTY] [int] NULL CONSTRAINT [DF_tblFT_Badges_pSlips_QTYCalc_originalQTY] DEFAULT ((0)),
[newQTY] [int] NULL CONSTRAINT [DF_tblFT_Badges_pSlips_QTYCalc_newQTY] DEFAULT ((0)),
[actualQTY] [int] NULL
) ON [PRIMARY]