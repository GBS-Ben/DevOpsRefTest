CREATE TABLE [dbo].[tblOrderView_lastRun]
(
[orderView_lastRun] [datetime] NOT NULL CONSTRAINT [DF_tbl_orderView_lastRun_orderView_lastRun] DEFAULT (getdate())
) ON [PRIMARY]