CREATE TABLE [dbo].[tblA1_MP]
(
[orderNo] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shipState] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GBSZone] [int] NULL,
[rdi] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPSRural] [bit] NULL,
[returnCode] [int] NULL,
[C24] [bit] NULL CONSTRAINT [DF_tblA1_MP_C24] DEFAULT ((0)),
[C24_QTY] [int] NULL,
[C72] [bit] NULL CONSTRAINT [DF_tblA1_MP_C72] DEFAULT ((0)),
[C72_QTY] [int] NULL,
[cnC24] [int] NULL,
[cnC72] [int] NULL,
[cnC24_C72] [int] NULL,
[cnAll_Targeted] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblA1_MP] ([orderNo]) ON [PRIMARY]