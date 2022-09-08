CREATE TABLE [dbo].[tempJF_Top20PercentCustomers_NS] (
    [SumLast365]       MONEY          NULL,
    [email]            NVARCHAR (255) NULL,
    [firstName]        NVARCHAR (255) NULL,
    [surname]          NVARCHAR (255) NULL,
    [numOrders365]     INT            NOT NULL,
    [numOrdersAllTime] INT            NOT NULL
);

