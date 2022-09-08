CREATE TABLE [dbo].[dash_dataCatalog] (
    [PKID]            INT           IDENTITY (1, 1) NOT NULL,
    [displayName]     VARCHAR (255) NOT NULL,
    [storedprocedure] VARCHAR (255) NULL,
    [parentID]        INT           NULL,
    [dataEditable]    BIT           DEFAULT ((0)) NULL,
    [hidden]          BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([PKID] ASC),
    CONSTRAINT [parentID_fk] FOREIGN KEY ([parentID]) REFERENCES [dbo].[dash_dataCatalog] ([PKID])
);


GO

GO
