CREATE PROCEDURE [dbo].[usp_AMZ_Intranet_getMarketPlace_Tab]
@tab VARCHAR(50)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/12/16
-- Purpose     This sproc grabs all AMZ orders for display on 
--					http://intranet/gbs/admin/orders_marketPlace.asp
-- Variables	This sproc accepts 4 different values for @tab. See below.
-- Example:		EXEC usp_AMZ_Intranet_getMarketPlaceTab 'In Transit'
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/12/16		Created.
-- 04/27/21		CKB, Markful
-------------------------------------------------------------------------------

--// set var
DECLARE @orderStatus VARCHAR (50) = ''

IF @tab = 'New'
	BEGIN
	SET @orderStatus = 'In House'
	END

IF @tab = 'In House'
	BEGIN
	SET @orderStatus = 'In House'
	END

IF @tab = 'On HOM Dock'
	BEGIN
	SET @orderStatus = 'Shipped'
	END

IF @tab = 'On MRK Dock'
	BEGIN
	SET @orderStatus = 'Shipped'
	END

IF @tab = 'In Transit'
	BEGIN
	SET @orderStatus = 'Shipped'
	END

IF @tab = 'Delivered'
	BEGIN
	SET @orderStatus = 'Delivered'
	END

--// grab data
SELECT DISTINCT
a.orderNo, 
a.[buyer-name] AS 'customerName',
CONVERT(DATETIME, a.orderDate) AS 'orderDate',
a.orderStatus,
a.modified_on AS 'statusUpdate',
b.[ship-service-level] AS 'shipMethod'
FROM tblAMZ_orderShip a
LEFT JOIN tblAMZ_orderValid b
	ON a.orderNo = b.orderNo
WHERE a.orderStatus = @orderStatus
ORDER BY CONVERT(DATETIME, a.orderDate) DESC, a.orderNo DESC