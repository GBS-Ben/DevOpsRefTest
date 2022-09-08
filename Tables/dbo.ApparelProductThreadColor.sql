CREATE TABLE [dbo].[ApparelProductThreadColor] (
    [id]                 INT            IDENTITY (1, 1) NOT NULL,
    [CompanyName]        NVARCHAR (255) NULL,
    [CompanyCode]        NVARCHAR (255) NULL,
    [ProductCode]        NVARCHAR (255) NULL,
    [CompanyApparelLogo] NVARCHAR (255) NULL,
    [Thread 1]           NVARCHAR (255) NULL,
    [Thread 2]           NVARCHAR (255) NULL,
    [Thread 3]           NVARCHAR (255) NULL,
    [Thread 4]           NVARCHAR (255) NULL,
    [Thread 5]           NVARCHAR (255) NULL,
    [Thread 6]           NVARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
