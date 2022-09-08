
	CREATE PROCEDURE REPORT_CalendarBuyers2022
	AS
	SET NOCOUNT ON;
	SELECT DISTINCT email
	FROM tblcustomers c 
	INNER JOIN tblOrders o on o.customerID = c.CustomerID
	INNER JOIN tblOrders_Products op ON op.orderID = o.orderID
	WHERE op.ProductCode liKE 'CA__00%'
		AND orderDate BETWEEN '07/13/2021' AND '05/01/2022'
		AND	 orderStatus NOT IN ('Cancelled')
		AND c.email NOT LIKE '%gogbs.com'