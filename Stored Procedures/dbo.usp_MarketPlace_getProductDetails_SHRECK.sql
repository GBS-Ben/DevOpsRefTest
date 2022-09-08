CREATE PROCEDURE [dbo].[usp_MarketPlace_getProductDetails_SHRECK]-- WEB224542
@orderNo VARCHAR(255)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/12/16
-- Purpose     This sproc grabs product details for a given AMZ @orderNo.
--					http://intranet/gbs/admin/orderView_MarketPlace.asp
-- Variables	This sproc accepts orderNos like "WEB123456' for @orderNo. See below.
-- Example:		EXEC usp_MarketPlace_getProductDetails 'WEB155928'
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/12/16		Created.
-------------------------------------------------------------------------------
--DECLARE @Customizations TABLE (rownum int identity(1,1), orderNo nvarchar(100), TitleText nvarchar(500), Font nvarchar(500), Color nvarchar(500))

-- INSERT @Customizations (orderNo, TitleText, Font, Color)
-- SELECT @orderNo,
----JSON_VALUE(BuyerCustomizedInfoJSON,'$.orderItemId') AS OrderItemId, 
----JSON_VALUE(BuyerCustomizedInfoJSON,'$.legacyOrderItemId') AS LegacyOrderItemId, 
----JSON_VALUE(BuyerCustomizedInfoJSON,'$.title') AS Title, 
----JSON_VALUE(BuyerCustomizedInfoJSON,'$.quantity') AS Quanity, 
----JSON_VALUE(BuyerCustomizedInfoJSON,'$.asin') AS [ASIN],
----JSON_VALUE(BuyerCustomizedInfoJSON,'$.customizationInfo.aspects[0].title') AS TitleName,
--JSON_VALUE(BuyerCustomizedInfoJSON,'$.customizationInfo.aspects[0].text.value') AS TitleText,
--JSON_VALUE(BuyerCustomizedInfoJSON,'$.customizationInfo.aspects[0].font.value') AS TitleFont,
--JSON_VALUE(BuyerCustomizedInfoJSON,'$.customizationInfo.aspects[0].color.value') AS TitleColor
--FROM tblAMZ_CustomizedInfoJSON c
---- where [order-item-id] = '08202855840666'
--INNER JOIN tblAMZ_orderValid v ON v.[order-item-id] = c.[order-item-id]
--WHERE v.orderNo = @orderNo


SELECT DISTINCT
PKID, a.[order-item-id],
[product-name], [sku], [quantity-purchased], [item-price], 
JSON_VALUE(BuyerCustomizedInfoJSON,'$.customizationInfo.aspects[0].text.value') AS	[TitleText], 
JSON_VALUE(BuyerCustomizedInfoJSON,'$.customizationInfo.aspects[0].font.value') AS	[TitleFont], 
JSON_VALUE(BuyerCustomizedInfoJSON,'$.customizationInfo.aspects[0].color.value') AS	[TitleColor]
FROM tblAMZ_orderValid a
LEFT JOIN tblAMZ_CustomizedInfoJSON c ON a.[order-item-id] = c.[order-item-id]
WHERE orderNo = @orderNo
ORDER BY [quantity-purchased] DESC, [product-name] ASC