CREATE PROCEDURE [dbo].[usp_MarketPlace_getProductDetails]-- WEB224542
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
--11/12/18		Added Customization data
-------------------------------------------------------------------------------


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