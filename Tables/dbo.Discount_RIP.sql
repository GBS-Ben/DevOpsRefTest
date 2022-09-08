CREATE TABLE [dbo].[Discount_RIP] (
    [DiscountRipId]              INT             IDENTITY (1, 1) NOT NULL,
    [Id]                         INT             NOT NULL,
    [DiscountId]                 INT             NOT NULL,
    [OrderId]                    INT             NOT NULL,
    [CreatedOnUtc]               DATETIME        NOT NULL,
    [CouponCode]                 NVARCHAR (100)  NULL,
    [DiscountAmount]             NUMERIC (18, 4) NOT NULL,
    [DiscountLimitationId]       INT             NOT NULL,
    [LimitationTimes]            INT             NOT NULL,
    [DiscountPercentage]         NUMERIC (18, 4) NOT NULL,
    [DiscountTypeId]             INT             NOT NULL,
    [IsCumulative]               BIT             NOT NULL,
    [StartDateUtc]               DATETIME        NULL,
    [EndDateUtc]                 DATETIME        NULL,
    [UsePercentage]              BIT             NOT NULL,
    [name]                       NVARCHAR (200)  NOT NULL,
    [AppliedToSubCategories]     BIT             NOT NULL,
    [NopOrderId]                 INT             NULL,
    [gbsOrderID]                 NVARCHAR (30)   NULL,
    [LocalVoucherId]             INT             NULL,
    [OrderDiscountAmountApplied] NUMERIC (18, 4) NULL,
    PRIMARY KEY CLUSTERED ([DiscountRipId] ASC)
);


GO
