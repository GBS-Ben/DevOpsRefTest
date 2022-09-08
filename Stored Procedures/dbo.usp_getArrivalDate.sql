CREATE PROC usp_getArrivalDate @orderNo NVARCHAR(20)
AS
	-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/30/18	
-- Purpose     Gets "Arrival Date" for specific order's orderDate value
-------------------------------------------------------------------------------
-- Modification History
--
--07/30/18		Created, jf.

-------------------------------------------------------------------------------

UPDATE a
SET ArrivalDate = (SELECT TOP 1 [DATE] 
								FROM dateDimension 
								WHERE DateKey IN (
										SELECT TOP 5 DateKey 
										FROM dateDimension 
										WHERE [DATE] > (SELECT orderDate
																		FROM tblOrders
																		WHERE orderNo = @orderNo)
										AND isWeekend = 0
										AND isHoliday = 0)
								ORDER BY [DATE] DESC)
FROM tblOrders a
WHERE a.orderStatus <> 'Delivered'
AND a.orderStatus <> 'cancelled'
AND a.orderStatus <> 'failed'
AND arrivalDate IS NULL