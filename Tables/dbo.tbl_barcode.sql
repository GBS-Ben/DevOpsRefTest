CREATE TABLE [dbo].[tbl_barcode] (
    [RecNo]        INT           NOT NULL,
    [Time_Stamp]   SMALLDATETIME NULL,
    [JobNo]        NVARCHAR (50) NULL,
    [Operation]    NVARCHAR (50) NULL,
    [Workcenter]   NVARCHAR (50) NULL,
    [trackingNo]   VARCHAR (50)  NULL,
    [lastImported] VARCHAR (255) NULL,
    [OPID]         INT           NULL,
    [OPIDStatus]   VARCHAR (255) NULL,
    CONSTRAINT [PK_tbl_barcode] PRIMARY KEY CLUSTERED ([RecNo] ASC)
);


GO

GO
CREATE NONCLUSTERED INDEX [IX_Barcode_JobNo_TrackingNo] ON [dbo].[tbl_barcode] ([JobNo], [trackingNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Barcode_timestamp_workcenter] ON [dbo].[tbl_barcode] ([Time_Stamp], [Workcenter]) INCLUDE ([JobNo]) ON [PRIMARY]