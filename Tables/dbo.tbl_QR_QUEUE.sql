CREATE TABLE [dbo].[tbl_QR_QUEUE] (
    [PKID]            BIGINT         IDENTITY (1, 1) NOT NULL,
    [url]             VARCHAR (255)  NOT NULL,
    [json]            NVARCHAR (MAX) NOT NULL,
    [destination]     VARCHAR (255)  NOT NULL,
    [Date_Added]      DATETIME       NOT NULL,
    [workflowControl] VARCHAR (255)  NULL,
    PRIMARY KEY CLUSTERED ([PKID] ASC)
);



