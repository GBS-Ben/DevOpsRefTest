CREATE PROCEDURE [dbo].[usp_AMZ_Intranet_getMarketPlace_OrderViewPage_Details]
@orderNo VARCHAR(255)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/12/16
-- Purpose     This sproc grabs product details for a given AMZ @orderNo.
--					http://intranet/gbs/admin/orderView_MarketPlace.asp
-- Variables	This sproc accepts orderNos like "WEB123456' for @orderNo. See below.
-- Example:		EXEC usp_AMZ_Intranet_getMarketPlace_OrderViewPage_Details 'WEB155928'
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/12/16		Created.
-------------------------------------------------------------------------------

SELECT DISTINCT
PKID, [order-item-id],
[product-name], [sku], [quantity-purchased], [item-price]
FROM tblAMZ_orderValid
WHERE orderNo = @orderNo
ORDER BY [quantity-purchased] DESC, [product-name] ASC