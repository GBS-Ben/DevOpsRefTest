CREATE TABLE [dbo].[GiftCard_RIP]
(
[Id] [int] NOT NULL,
[PurchasedWithOrderItemId] [int] NULL,
[GiftCardTypeId] [int] NOT NULL,
[Amount] [numeric] (18, 4) NOT NULL,
[IsGiftCardActivated] [bit] NOT NULL,
[GiftCardCouponCode] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SenderName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SenderEmail] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRecipientNotified] [bit] NOT NULL,
[CreatedOnUtc] [datetime] NOT NULL
) ON [PRIMARY]