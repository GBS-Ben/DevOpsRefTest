CREATE PROC [dbo].[usp_getOrdersNewStock]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/20/16
-- Purpose     Retrieves stock items for ordersNewStock.asp in the Intranet.
-------------------------------------------------------------------------------
-- Modification History
--
-- 12/8/16		creation; jf.

-------------------------------------------------------------------------------

SELECT a.orderID, a.customerID, a.orderDate, a.orderNo, a.orderTotal, 
a.paymentAmountRequired, a.paymentMethod, a.orderStatus, a.statusDate, a.lastStatusUpdate, 
a.orderType, a.shippingMethod, a.shippingDesc, a.storeID, c.firstName, c.surname 
FROM tblOrders a 
JOIN tblCustomers c 
	ON a.customerID = c.customerID 
WHERE
--normal parameters
a.archived = 0 
AND (
	 (a.paymentProcessed = 1 AND a.paymentSuccessful = 1) 
	 OR 
	 (a.paymentMethodID = 9)
	 )
AND a.tabStatus = 'Valid'
AND a.a1 <> 1 
AND a.orderStatus NOT IN ('Delivered', 'Failed', 'Cancelled', 'In Transit', 'In Transit USPS')

--pull in all stock orders
AND (a.orderType = 'Stock' 
	 OR
--add stock OPIDs from orders that also contain subcontracted OPIDs, since we still need to print the stock items and ship them out. 
	 a.orderType = 'fasTrak' 
	 AND a.orderID IN 
		 (SELECT orderID 
		 FROM tblOrders_Products 
		 WHERE deleteX <> 'yes' 
		 AND productID IN 
			 (SELECT productID 
			 FROM tblProducts 
			 WHERE subContract = 1)) 
	 AND a.orderID IN 
		 (SELECT orderID 
		 FROM tblOrders_Products 
		 WHERE deleteX <> 'yes' 
		 AND productID IN 
			 (SELECT productID 
			 FROM tblProducts 
			 WHERE productType = 'Stock')
-- remove stock OPIDs from orders that also contain non-subcontracted fasTrak OPIDs in the order, since the stock OPIDs would instead ship via the fasTrak tab.
	AND a.orderID NOT IN 
		(SELECT orderID 
		FROM tblOrders
		WHERE orderStatus NOT IN ('Delivered', 'Failed', 'Cancelled', 'In Transit', 'In Transit USPS')
		AND orderID IN
		(SELECT orderID
		FROM tblOrders_Products 
		WHERE deleteX <> 'yes' 
		AND productID IN 
			(SELECT productID 
			FROM tblProducts 
			WHERE subContract = 0 
			AND productType = 'fasTrak')))))