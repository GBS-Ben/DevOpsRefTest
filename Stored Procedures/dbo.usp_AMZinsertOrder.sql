CREATE PROCEDURE [dbo].[usp_AMZinsertOrder]
-- =============================================
-- Author:		<Ron Norman>
-- Create date: <November 2, 2012>
-- Description:	<usp_AMZinsertOrder>
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
	@currency nvarchar(255) = NULL,
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

INSERT INTO  tblAMZ_orderImporter
           ([order-id]
           ,[order-item-id]
           ,[purchase-date]
           ,[buyer-email]
           ,[buyer-name]
           ,[buyer-phone-number]
           ,[sku]
           ,[product-name]
           ,[quantity-purchased]
           ,[quantity-to-ship]
           ,[currency]
           ,[item-price]
           ,[item-tax]
           ,[ship-service-level]
           ,[recipient-name]
           ,[ship-address-1]
           ,[ship-address-2]
           ,[ship-address-3]
           ,[ship-city]
           ,[ship-state]
           ,[ship-postal-code]
           ,[ship-country]
           ,[ship-phone-number]
           ,[item-promotion-discount]
           ,[item-promotion-id]
		   ,[BuyerCustomizedInfoCustomizedURL]
			)
     VALUES
           (@order_id 
           ,@order_item_id 
           ,@purchase_date 
           ,@buyer_email 
           ,@buyer_name 
           ,@buyer_phone_number 
           ,@sku 
           ,@product_name 
           ,@quantity_purchased 
           ,@quantity_to_ship 
           ,ISNULL(@currency,'USD')
           ,@item_price 
           ,@item_tax 
           ,@ship_service_level 
           ,@recipient_name 
           ,@ship_address_1 
           ,@ship_address_2 
           ,@ship_address_3 
           ,@ship_city 
           ,@ship_state 
           ,@ship_postal_code 
           ,@ship_country 
           ,@ship_phone_number 
           ,@item_promotion_discount
           ,@item_promotion_id
		   ,@BuyerCustomizedInfoCustomizedURL
           )
END