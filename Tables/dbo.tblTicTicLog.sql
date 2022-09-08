CREATE TABLE [dbo].[tblTicTicLog] (
    [ID]                   INT              NOT NULL,
    [itemGUID]             UNIQUEIDENTIFIER NOT NULL,
    [OrderId]              INT              NOT NULL,
    [orderNo]              NVARCHAR (50)    NOT NULL,
    [ordersProductsId]     INT              NOT NULL,
    [ProcessChannel]       INT              NOT NULL,
    [ProcessBeginDateTime] DATETIME         CONSTRAINT [DF__tblTicTicLog__ProcessBeginDate] DEFAULT (getdate()) NOT NULL,
    [ProcessEndDateTime]   DATETIME         NULL,
    [ProcessStatus]        VARCHAR (255)    NULL,
    [ProcessError]         NVARCHAR (4000)  NULL,
    [ticticType]           VARCHAR (10)     NULL,
    [workflowControl]      VARCHAR (255)    NULL
);

