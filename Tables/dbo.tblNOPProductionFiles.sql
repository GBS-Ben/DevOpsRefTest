CREATE TABLE [dbo].[tblNOPProductionFiles] (
    [ID]                 INT             IDENTITY (1, 1) NOT NULL,
    [nopOrderItemID]     INT             NOT NULL,
    [ProductType]        NVARCHAR (100)  NULL,
    [FileName]           NVARCHAR (400)  NOT NULL,
    [gbsOrderID]         VARCHAR (50)    NULL,
    [ccid]               INT             NULL,
    [Surface]            NVARCHAR (400)  NULL,
    [CanvasURL]          NVARCHAR (1000) NULL,
    [CreateDate]         DATETIME2 (7)   DEFAULT (getdate()) NULL,
    [ModifiedDate]       DATETIME2 (7)   DEFAULT (getdate()) NULL,
    [CanvasPdfFetchDate] DATETIME2 (7)   NULL,
    [RetryDate]          DATETIME2 (7)   NULL,
    [RetryCount]         INT             DEFAULT ((0)) NULL,
    [InfoBlock]          VARCHAR (MAX)   NULL,
    [RemoteID]           INT             NULL,
    CONSTRAINT [PK_tblNOPProductionFiles_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);


GO

GO
CREATE NONCLUSTERED INDEX [NCI_FileName] ON [dbo].[tblNOPProductionFiles] ([FileName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblNOPProductionFiles_nopOrderItemID] ON [dbo].[tblNOPProductionFiles] ([nopOrderItemID]) WITH (FILLFACTOR=90) ON [PRIMARY]