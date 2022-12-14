CREATE TABLE [dbo].[tblAMZN_Orders_Stage]
(
[amazon-order-id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[merchant-order-id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase-date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last-updated-date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order-status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fulfillment-channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sales-channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[order-channel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[url] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-service-level] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[product-name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sku] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item-status] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[currency] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item-price] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item-tax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping-price] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping-tax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gift-wrap-price] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gift-wrap-tax] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item-promotion-discount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-promotion-discount] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-city] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-postal-code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ship-country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[promotion-ids] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is-business-order] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[purchase-order-number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[price-designation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customized-url] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[customized-page ] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InputFileName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dateCreated] [datetime] NOT NULL CONSTRAINT [DF_tblAMZN_Orders_Stage_dateCreated] DEFAULT (getdate())
) ON [PRIMARY]