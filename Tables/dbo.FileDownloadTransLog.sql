CREATE TABLE [dbo].[FileDownloadTransLog] (
    [logId]         BIGINT        NULL,
    [StatusMessage] VARCHAR (255) NULL,
    [CreatedDate]   DATETIME2 (7) DEFAULT (getdate()) NULL
);

