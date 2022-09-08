CREATE TABLE [dbo].[CustomArtEmailLog] (
    [OrderID]     INT            NOT NULL,
    [OrderNo]     NVARCHAR (20)  NOT NULL,
    [OPID]        INT            NOT NULL,
    [emailSent]   BIT            NOT NULL,
    [emailSentTo] NVARCHAR (225) NOT NULL,
    [emailSentON] DATETIME       NOT NULL
);

