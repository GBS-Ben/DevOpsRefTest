CREATE TABLE [dbo].[tbl_QR_Log] (
    [PKID]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [QueueID]            BIGINT         NOT NULL,
    [url]                VARCHAR (255)  NOT NULL,
    [json]               NVARCHAR (MAX) NOT NULL,
    [destination]        VARCHAR (255)  NOT NULL,
    [channel]            INT            NOT NULL,
    [Date_Added]         DATETIME       NOT NULL,
    [Process_Start_Date] DATETIME       NOT NULL,
    [Process_End_Date]   DATETIME       NULL,
    [Process_Status]     VARCHAR (255)  NULL,
    [Process_Error]      VARCHAR (255)  NULL,
    [workflowControl]    VARCHAR (255)  NULL,
    PRIMARY KEY CLUSTERED ([PKID] ASC)
);



