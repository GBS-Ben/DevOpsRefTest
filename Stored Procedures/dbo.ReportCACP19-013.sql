CREATE PROCEDURE [dbo].[ReportCACP19-013]
AS
-------------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     8/6/07
-- Purpose     Retrieves CACP data for CACP19-013
-------------------------------------------------------------------------------------
-- Modification History
-- 01/21/19	create, jf.
-------------------------------------------------------------------------------------
SELECT DISTINCT REPLACE(c.EMAIL, '"', '') AS 'Email'
FROM tblOrders o
INNER JOIN tblCustomers c ON o.customerID = c.customerID
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND op.productCode = 'CACP19-013'