CREATE TABLE [dbo].[ProcessExecutionLog] (
    [ExecutionLogId]     INT           IDENTITY (1, 1) NOT NULL,
    [EventName]          VARCHAR (100) NULL,
    [ExecutionStartDate] DATETIME      NULL,
    [ExecutionEndDate]   DATETIME      NULL,
    [StatusMessage]      VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([ExecutionLogId] ASC)
);


GO
