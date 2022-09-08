CREATE PROC usp_getAnnualFYE
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     02/15/18
-- Purpose     Gets Annual FYE numbers for Chris Gordon.
-------------------------------------------------------------------------------
-- Modification History
--
-- 02/15/18	Created, JF
-------------------------------------------------------------------------------

-- # of customers
SELECT COUNT(DISTINCT(email))
FROM tblcustomers
WHERE customerID IN
	(SELECT customerID
	FROM tblorders
	WHERE orderStatus NOT IN ('Failed', 'Cancelled')
	AND DATEPART(YY, orderDate) = '2017') --65313

-- # of orders
SELECT COUNT(orderNo)
FROM tblorders
WHERE orderStatus NOT IN ('Failed', 'Cancelled')
AND DATEPART(YY, orderDate) = '2017' --104526

-- # total rev
SELECT SUM(orderTotal)
FROM tblorders
WHERE orderStatus NOT IN ('Failed', 'Cancelled')
AND DATEPART(YY, orderDate) = '2017' --8815500.88

-- avg order value (total rev/# of orders)
SELECT 8815500.88/104526 --84.337876509

-- # of orders per customer (# of orders/# of distinct customers)
SELECT 104526/65313 -- 1.600385

-- annual customer value ((total rev/# orders per customer)/
SELECT 1.600385*(8815500.88/104526) -- 134.973072496855965