CREATE PROC usp_getMonthlyNew
@MM VARCHAR(10), @YY VARCHAR(10)
AS
SELECT COUNT(DISTINCT(customerID))
FROM tblOrders
WHERE orderStatus <> 'cancelled'
AND orderStatus <> 'failed'
AND DATEPART(MM, orderDate) = @MM
AND DATEPART(YY, orderDate) = @YY
AND customerID NOT IN
	(SELECT DISTINCT customerID
	FROM tblOrders
	WHERE orderStatus <> 'cancelled'	
	AND orderStatus <> 'failed'
	AND orderDate < CONVERT(DATETIME, @MM + '/01/' + @YY))