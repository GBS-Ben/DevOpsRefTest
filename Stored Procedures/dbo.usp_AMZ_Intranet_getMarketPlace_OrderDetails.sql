CREATE PROCEDURE [dbo].[usp_AMZ_Intranet_getMarketPlace_OrderDetails]
@orderNo VARCHAR(255)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/12/16
-- Purpose     This sproc grabs general AMZ order data for a given @orderNo.
--					http://intranet/gbs/admin/orderView_MarketPlace.asp
-- Variables	This sproc accepts orderNos like "WEB123456' for @orderNo. See below.
-- Example:		EXEC usp_AMZ_Intranet_getMarketPlace_OrderDetails 'WEB123456'
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/12/16		Created.
-------------------------------------------------------------------------------

SELECT DISTINCT
a.[orderNo],
a.[buyer-name], a.[buyer-phone-number], a.[buyer-email], a.[order-id],
a.[recipient-name], a.[ship-address-1], a.[ship-address-2], a.[ship-address-3],
a.[ship-city], a.[ship-state], a.[ship-postal-code], a.[ship-country], 
a.[orderDate], 
b.[ship-service-level], b.[promise-date]
FROM tblAMZ_orderShip a
LEFT JOIN tblAMZ_orderValid b
	ON a.orderNo = b.orderNo
WHERE a.orderNo = @orderNo