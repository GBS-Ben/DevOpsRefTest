CREATE TABLE [dbo].[tblPayLater] (
    [Id]                             INT              IDENTITY (1, 1) NOT NULL,
    [OrderId]                        INT              NOT NULL,
    [OrderNo]                        VARCHAR (100)    NULL,
    [OrderDate]                      DATETIME2 (7)    NULL,
    [PaymentAmountRequired]          DECIMAL (14, 8)  NULL,
    [CustomerId]                     INT              NULL,
    [CardType]                       VARCHAR (100)    NULL,
    [CardNumberLast4]                VARCHAR (10)     NULL,
    [AuthorizationTransactionId]     NVARCHAR (MAX)   NULL,
    [AuthorizationTransactionCode]   NVARCHAR (MAX)   NULL,
    [AuthorizationTransactionResult] NVARCHAR (MAX)   NULL,
    [PaidDateUtc]                    DATETIME         NULL,
    [CreatedOnUtc]                   DATETIME2 (7)    DEFAULT (getdate()) NOT NULL,
    [PaymentProcessDate]             DATETIME2 (7)    NULL,
    [LastEmailDate]                  DATETIME2 (7)    NULL,
    [LastEmailRecipient]             NVARCHAR (255)   NULL,
    [PaymentLink]                    NVARCHAR (500)   NULL,
    [OrderName]                      VARCHAR (255)    NULL,
    [PaymentRequestID]               UNIQUEIDENTIFIER CONSTRAINT [DF_tblPayLater_PayLaterGUID] DEFAULT (newid()) NOT NULL,
    [ActiveFlag]                     BIT              CONSTRAINT [DF_tblPayLater_ActiveFlag] DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
