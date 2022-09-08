CREATE TABLE [dbo].[InfoBlockData] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [ordersProductId] INT            NULL,
    [Key]             NVARCHAR (255) NULL,
    [value]           NVARCHAR (MAX) NULL,
    [createdOn]       DATETIME2 (7)  DEFAULT (getdate()) NULL,
    [updatedOn]       DATETIME2 (7)  NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
