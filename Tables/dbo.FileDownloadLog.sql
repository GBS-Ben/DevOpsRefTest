CREATE TABLE [dbo].[FileDownloadLog] (
    [logId]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [OrdersProductsId]  INT           NULL,
    [DownloadFileName]  VARCHAR (500) NULL,
    [DownloadUNCFile]   VARCHAR (500) NULL,
    [DownloadUrl]       VARCHAR (500) NULL,
    [DownloadStartDate] DATETIME2 (7) NULL,
    [DownloadEndDate]   DATETIME2 (7) NULL,
    [StatusMessage]     VARCHAR (255) NULL,
    [ReTryDate]         DATETIME2 (7) NULL,
    [ReTryCount]        INT           NULL,
    [CreatedDate]       DATETIME2 (7) DEFAULT (getdate()) NULL,
    [ModifiedDate]      DATETIME2 (7) NULL,
    [WorkflowControl]   VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([logId] ASC)
);




GO

GO
CREATE NONCLUSTERED INDEX [IX_FileDownloadLog_DownloadStartStatusMessageEtc] ON [dbo].[FileDownloadLog] ([DownloadStartDate], [StatusMessage], [DownloadUNCFile]) INCLUDE ([CreatedDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FileDownloadLog_OrdersProductsId] ON [dbo].[FileDownloadLog] ([OrdersProductsId], [DownloadFileName], [DownloadUrl]) INCLUDE ([logId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FileDownloadLog_StatusMessage] ON [dbo].[FileDownloadLog] ([StatusMessage]) INCLUDE ([DownloadFileName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FileDownloadLog_StatusMessage_DownloadUNCFile] ON [dbo].[FileDownloadLog] ([StatusMessage]) INCLUDE ([DownloadUNCFile]) ON [PRIMARY]