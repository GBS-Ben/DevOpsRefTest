CREATE PROC [dbo].[usp_UpdateShipFlag]
AS
-------------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/05/15
-- Purpose     
--					Updates A1 (all in one ticket) orders for use by [usp_ShippingLabels]
--					and also by the A1 tab on the Intranet.
--					This is called by job "INT__update_ShipFlag" which runs that sproc, which in turn runs this sproc, every 29m.
-------------------------------------------------------------------------------------
-- Modification History
-- 10/05/15		New
-- 12/19/17		Updated, jf.
-------------------------------------------------------------------------------------

UPDATE tblOrders
SET A1_expediteShipFlag = 1
WHERE A1_expediteShipFlag = 0
AND CONVERT(NVARCHAR(255), shippingDesc) IN
	('UPS 3 Day Select', 'UPS 2nd Day Air', 'WillCall', 'Local Pickup', 'Other', '3 Day Ground', 'UPS Next Day Air', '2 Day Air', 
	'WillCall', 'UPS Next Day Air Saver', 'Next Day', 'FedEx', 'Other', 'FedEx', 'UPS 2nd Day Air A.M.', 'UPS - UPS 3 Day Select&reg;', 
	'TBD', 'UPS - UPS 2nd Day Air&reg;', 'Conway', 'UPS 3 Day Select', 'UPS 3 Day Select', 'UPS 2nd Day Air', 
	'UPS Next Day Air Saver', 'Conway', 'DHL', 'UPS - UPS Next Day Air&reg;', 'UPS Next Day Air', 'UPS Next Day Air Saturday',
	'2 Day Air Shipping', ' 2nd Day Air', ' 3 Day Select', ' Next Day Air', '3 Day Ground Shipping', 'Next Day Shipping', 'UPS Next Day Air Sat Delivery') 
AND orderStatus NOT IN ('delivered', 'failed', 'cancelled')
AND DATEDIFF(MM, orderDate, GETDATE()) < 12

UPDATE tblOrders
SET A1_expediteShipFlag = 0
WHERE A1_expediteShipFlag = 1
AND CONVERT(NVARCHAR(255), shippingDesc) NOT IN
	('UPS 3 Day Select', 'UPS 2nd Day Air', 'WillCall', 'Local Pickup', 'Other', '3 Day Ground', 'UPS Next Day Air', '2 Day Air', 
	'WillCall', 'UPS Next Day Air Saver', 'Next Day', 'FedEx', 'Other', 'FedEx', 'UPS 2nd Day Air A.M.', 'UPS - UPS 3 Day Select&reg;', 
	'TBD', 'UPS - UPS 2nd Day Air&reg;', 'Conway', 'UPS 3 Day Select', 'UPS 3 Day Select', 'UPS 2nd Day Air', 
	'UPS Next Day Air Saver', 'Conway', 'DHL', 'UPS - UPS Next Day Air&reg;', 'UPS Next Day Air', 'UPS Next Day Air Saturday',
	'2 Day Air Shipping', ' 2nd Day Air', ' 3 Day Select', ' Next Day Air', '3 Day Ground Shipping', 'Next Day Shipping', 'UPS Next Day Air Sat Delivery') 
AND orderStatus NOT IN ('delivered', 'failed', 'cancelled')
AND DATEDIFF(MM, orderDate, GETDATE()) < 12

/*
--run this query to view other recently used shipping descriptions that are randomly entered that are not listed above, then add to above:

	select distinct (CONVERT(NVARCHAR(255), shippingDesc)) from tblorders where
	(CONVERT(NVARCHAR(255), shippingDesc)  LIKE '%ship%'
	OR
	CONVERT(NVARCHAR(255), shippingDesc)  LIKE '%local%'
		OR
	CONVERT(NVARCHAR(255), shippingDesc)  LIKE '%air%'
		OR
	CONVERT(NVARCHAR(255), shippingDesc)  LIKE '%next%'
			OR
	CONVERT(NVARCHAR(255), shippingDesc)  LIKE '%day%'

	)
	AND CONVERT(NVARCHAR(255), shippingDesc) NOT IN
	('UPS 3 Day Select', 'UPS 2nd Day Air', 'WillCall', 'Local Pickup', 'Other', '3 Day Ground', 'UPS Next Day Air', '2 Day Air', 
	'WillCall', 'UPS Next Day Air Saver', 'Next Day', 'FedEx', 'Other', 'FedEx', 'UPS 2nd Day Air A.M.', 'UPS - UPS 3 Day Select&reg;', 
	'TBD', 'UPS - UPS 2nd Day Air&reg;', 'Conway', 'UPS 3 Day Select', 'UPS 3 Day Select', 'UPS 2nd Day Air', 
	'UPS Next Day Air Saver', 'Conway', 'DHL', 'UPS - UPS Next Day Air&reg;', 'UPS Next Day Air', 'UPS Next Day Air Saturday',
	'2 Day Air Shipping', ' 2nd Day Air', ' 3 Day Select', ' Next Day Air', '3 Day Ground Shipping', 'Next Day Shipping', 'UPS Next Day Air Sat Delivery') 
	AND DATEDIFF(YY,orderDate, getdate()) < 1
*/