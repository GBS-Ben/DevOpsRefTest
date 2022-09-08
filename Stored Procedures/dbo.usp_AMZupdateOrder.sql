CREATE PROCEDURE [dbo].[usp_AMZupdateOrder]
-- =============================================
-- Author:		<Ron Norman>
-- Create date: <November 5, 2012>
-- Description:	usp_AMZuupdateOrder


--10/22/18	BJS	Modified to handle CustomInfo URL
-- =============================================
	-- Add the parameters for the stored procedure here
	@order_id nvarchar(255),
	@order_item_id nvarchar(255),
	@purchase_date nvarchar(255),
	@buyer_email nvarchar(255),
	@buyer_name nvarchar(255) = '',
	@buyer_phone_number nvarchar(255),
	@sku nvarchar(255),
	@product_name nvarchar(255),
	@quantity_purchased nvarchar(255),
	@quantity_to_ship nvarchar(255),
	@currency nvarchar(255),
	@item_price nvarchar(255),
	@item_tax nvarchar(255),
	@ship_service_level nvarchar(255),
	@recipient_name nvarchar(255) = '',
	@ship_address_1 nvarchar(255),
	@ship_address_2 nvarchar(255),
	@ship_address_3 nvarchar(255),
	@ship_city nvarchar(255),
	@ship_state nvarchar(255),
	@ship_postal_code nvarchar(255),
	@ship_country nvarchar(255),
	@ship_phone_number nvarchar(255),
	@item_promotion_discount nvarchar(255),
	@item_promotion_id nvarchar(255),
	@BuyerCustomizedInfoCustomizedURL nvarchar(500)	= NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

UPDATE [tblAMZ_orderImporter]
   SET [order-id] = @order_id 
      ,[order-item-id] = @order_item_id 
      ,[purchase-date] = @purchase_date 
      ,[buyer-email] = @buyer_email 
      ,[buyer-name] = @buyer_name 
      ,[buyer-phone-number] = @buyer_phone_number
      ,[sku] = @sku
      ,[product-name] = @product_name 
      ,[quantity-purchased] = @quantity_purchased 
      ,[quantity-to-ship] = @quantity_to_ship 
      ,[currency] = @currency 
      ,[item-price] = @item_price 
      ,[item-tax] = @item_tax
      ,[ship-service-level] = @ship_service_level 
      ,[recipient-name] = @recipient_name 
      ,[ship-address-1] = @ship_address_1 
      ,[ship-address-2] = @ship_address_2
      ,[ship-address-3] = @ship_address_3
      ,[ship-city] = @ship_city
      ,[ship-state] = @ship_state
      ,[ship-postal-code] = @ship_postal_code
      ,[ship-country] = @ship_country
      ,[ship-phone-number] = @ship_phone_number
      ,[item-promotion-discount] = @item_promotion_discount
      ,[item-promotion-id] = @item_promotion_id
	  ,[BuyerCustomizedInfoCustomizedURL] = @BuyerCustomizedInfoCustomizedURL
 WHERE [order-id] = @order_id AND [order-item-id] = @order_item_id
 
 END