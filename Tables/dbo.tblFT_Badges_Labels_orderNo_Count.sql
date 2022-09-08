CREATE TABLE [dbo].[tblFT_Badges_Labels_orderNo_Count]
(
[orderNo] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QTY] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_orderNo] ON [dbo].[tblFT_Badges_Labels_orderNo_Count] ([orderNo]) WITH (FILLFACTOR=90) ON [PRIMARY]