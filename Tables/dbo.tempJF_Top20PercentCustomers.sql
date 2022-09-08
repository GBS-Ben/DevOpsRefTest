CREATE TABLE [dbo].[tempJF_Top20PercentCustomers] (
    [SumLast365]       MONEY          NULL,
    [email]            NVARCHAR (255) NULL,
    [firstName]        NVARCHAR (255) NULL,
    [surname]          NVARCHAR (255) NULL,
    [numOrders365]     INT            NOT NULL,
    [numOrdersAllTime] INT            NOT NULL,
    [GBSCompanyID]     VARCHAR (255)  NULL,
    [ShopName]         VARCHAR (255)  NULL
);

