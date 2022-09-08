CREATE TABLE [dbo].[ProcessStatus] (
    [processName]       VARCHAR (255)  NOT NULL,
    [intervalMinutes]   INT            NOT NULL,
    [baseTime]          VARCHAR (8)    NULL,
    [weekdayOnly]       BIT            CONSTRAINT [DF_ProcessStatus_weekdayOnly] DEFAULT ((1)) NOT NULL,
    [notificationEmail] VARCHAR (2000) NOT NULL,
    [lastRunDateTime]   DATETIME       NULL
);

