CREATE TABLE [dbo].[tblTicTicQueue] (
    [ID]               INT              IDENTITY (1, 1) NOT NULL,
    [itemGUID]         UNIQUEIDENTIFIER DEFAULT (newid()) NOT NULL,
    [orderId]          INT              NOT NULL,
    [orderNo]          NVARCHAR (50)    NOT NULL,
    [ordersProductsId] INT              NOT NULL,
    [ticticType]       VARCHAR (10)     NULL,
    [workflowControl]  VARCHAR (255)    NULL
);

