CREATE TABLE [dbo].[ImposerControl] (
    [PKID]            INT           NOT NULL,
    [impoName]        VARCHAR (20)  NOT NULL,
    [impoStatus]      INT           NOT NULL,
    [storedProcedure] VARCHAR (20)  NOT NULL,
    [impoNum]         INT           NOT NULL,
    [impoLayout]      VARCHAR (20)  NOT NULL,
    [ticketLayout]    VARCHAR (20)  NOT NULL,
    [plex]            INT           DEFAULT ((1)) NOT NULL,
    [autoImpoTiming]  INT           NULL,
    [ticketType]      VARCHAR (255) DEFAULT ('single') NOT NULL
);

