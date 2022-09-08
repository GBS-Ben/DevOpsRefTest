CREATE TABLE [dbo].[dashboard_reviewedProducts] (
    [id]               INT      IDENTITY (1, 1) NOT NULL,
    [ordersProductsID] INT      NOT NULL,
    [reviewedOn]       DATETIME NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
