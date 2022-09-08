CREATE FUNCTION [dbo].[fnFT_validateOrder] (@orderID INT)
RETURNS BIT
AS
/*
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/23/18
-- Purpose     Qualifies order-centric values for given OPID for automation. Used in fasTrak/Switch/etc.
-------------------------------------------------------------------------------
-- Modification History

-- 07/23/18		Created.
-------------------------------------------------------------------------------
*/
BEGIN
DECLARE @valid INT = 0

	SET @valid = (SELECT 1
							FROM tblOrders o
							WHERE DATEDIFF(MI, o.created_on, GETDATE()) > 10
							AND o.orderDate > CONVERT(DATETIME, '02/01/2018')
							AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
							AND o.displayPaymentStatus = 'Good'
							AND o.orderID =  @orderID)

	IF @valid IS NULL
	BEGIN
		SET @valid = 0
	END

RETURN @valid
END