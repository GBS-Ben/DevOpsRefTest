CREATE TABLE [dbo].[Session] (
    [sessionId]      NVARCHAR (450) NOT NULL,
    [sessionData]    NVARCHAR (MAX) NULL,
    [lastTouchedUtc] DATETIME       NOT NULL,
    PRIMARY KEY CLUSTERED ([sessionId] ASC)
);


GO
