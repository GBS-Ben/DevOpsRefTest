CREATE TABLE [dbo].[WIPLog] (
    [RecNo]                INT           NOT NULL,
    [Time_Stamp]           SMALLDATETIME NULL,
    [JobNo]                NVARCHAR (50) NULL,
    [Operation]            NVARCHAR (50) NULL,
    [Workcenter]           NVARCHAR (50) NULL,
    [TrackingNo]           NVARCHAR (50) NULL,
    [importedSuccessfully] BIT           CONSTRAINT [DF_WIPLog_importedSuccessfully] DEFAULT ((0)) NOT NULL,
    [OPID]                 INT           NULL
);

