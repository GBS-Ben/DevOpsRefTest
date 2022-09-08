CREATE PROCEDURE [dbo].[usp_TabCount]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     07/26/12
Purpose		Updates paranthetical tab counts on Intranet Tabs
-------------------------------------------------------------------------------
Modification History

07/26/12	Created, jf.
07/30/18	Cleaned up a lil, jf.
10/24/18	Updated Custom Tab Count, Stock Tab Count by removing 'AND tblcustomers.firstName<>''' clause, jf.
10/24/18	Updated Stock tab count to include the FT/pen thing, jf.
10/19/20	JF, updated neworderscustom. Now looks at op.processType and op.isPrinted.
04/27/21	CKB, Markful
-------------------------------------------------------------------------------
*/ 
--// PART ONE (LOWER TABS)
UPDATE tblTabCount
SET ordersallinhouse = (SELECT COUNT(orderID)
						FROM tblOrders
						WHERE archived = 0
						AND tabStatus <> 'Failed'
						AND orderStatus = 'In House')

UPDATE tblTabCount
SET ordersallinart = (SELECT COUNT(orderID)
						FROM tblOrders
						WHERE archived = 0
						AND tabStatus <> 'Failed'
						AND orderStatus IN ('In Art', 'Waiting for New Art', 'Waiting On Customer', 'In Art for Changes'))

UPDATE tblTabCount
SET ordersallinpro = (SELECT COUNT(orderID)
					FROM tblOrders
					WHERE archived = 0
					AND tabStatus <> 'Failed'
					AND orderStatus = 'In Production')

UPDATE tblTabCount
SET ordersallgtg = (SELECT COUNT(orderID)
					FROM tblOrders
					WHERE archived = 0
					AND tabStatus <> 'Failed'
					AND orderStatus IN ('Good To Go', 'GTG-Waiting for Payment'))

UPDATE tblTabCount
SET ordersallwfp = (SELECT COUNT(orderID)
					FROM tblOrders
					WHERE archived = 0
					AND tabStatus <> 'Failed'
					AND orderStatus = 'Waiting For Payment')

UPDATE tblTabCount
SET ordersallondock = (SELECT COUNT(orderID)
						FROM tblOrders
						WHERE archived = 0
						AND tabStatus <> 'Failed'
						AND orderStatus IN ('On HOM Dock','On MRK Dock'))

UPDATE tblTabCount
SET ordersallonproof = (SELECT COUNT(orderID)
						FROM tblOrders
						WHERE archived = 0
						AND orderStatus = 'On Proof')

UPDATE tblTabCount
SET ordersallintrans = (SELECT COUNT(orderID)
						FROM tblOrders
						WHERE archived = 0
						AND tabStatus <> 'Failed'
						AND orderStatus IN ('In Transit', 'In Transit USPS', 'In Transit USPS (Stamped)'))

--// PART TWO (HIGHER TABS)	 
UPDATE tblTabCount
SET newordersstock = (SELECT COUNT(orderID)
						FROM tblOrders o
						WHERE o.orderAck = 0
						AND o.archived = 0
						AND ((o.paymentProcessed = 1 AND o.paymentSuccessful = 1) 
							OR (o.paymentMethodID = 9)) 
						AND o.tabStatus = 'Valid'
						AND o.a1 <> 1 
						AND o.orderStatus NOT IN ('MIGZ', 'Cancelled', 'Failed', 'Delivered', 'In Transit', 'In Transit USPS', 'In Transit USPS (Stamped)')
						AND (o.orderType = 'Stock' --obviously
							OR o.orderType = 'fasTrak' -- so, if it's gonna be fastrak, it needs to have three addtl quals:
								AND o.orderID IN 
											(SELECT orderID 
											FROM tblOrders_Products 
											WHERE deleteX <> 'yes' 
											AND productID IN 
												(SELECT productID 
												FROM tblProducts 
												WHERE subContract = 1)) -- pens
								AND o.orderID IN 
											(SELECT orderID 
											FROM tblOrders_Products 
											WHERE deleteX <> 'yes' 
											AND productID IN 
												(SELECT productID 
												FROM tblProducts 
												WHERE productType = 'Stock')) -- has an addtl stock product in order
								AND o.orderID NOT IN 
											(SELECT orderID 
											FROM tblOrders_Products 
											WHERE deleteX <> 'yes' 
											AND productID IN 
												(SELECT productID 
												FROM tblProducts 
												WHERE subContract = 0 
												AND productType = 'fasTrak')))) -- yet, has no FT product in order

UPDATE tblTabCount
SET neworderscustom = (SELECT COUNT(DISTINCT(o.orderID))
						FROM tblOrders o 
						LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
						INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
						WHERE o.orderack = 0
						AND o.archived = 0
						AND op.processType = 'Custom'
						AND op.isPrinted = 0
						AND o.tabStatus NOT IN ('Failed', 'Exception')
						AND op.deleteX <> 'yes' 
						AND o.tabStatus NOT IN ('Failed', 'Exception')
						AND o.orderStatus NOT IN ('MIGZ', 'Cancelled', 'Failed', 'Delivered', 'In Transit', 'In Transit USPS'))

UPDATE tblTabCount
SET neworderswaiting = (SELECT COUNT(paymentprocessed)
						FROM tblOrders
						WHERE archived = 0
						AND paymentsuccessful = 0
						AND tabStatus IN ('Offline', 'Faxed', 'CheckCash')
						AND orderStatus NOT IN ('MIGZ', 'Failed', 'Cancelled'))

UPDATE tblTabCount
SET newordersexcept = (SELECT COUNT(paymentprocessed)
						FROM tblOrders
						WHERE archived = 0
						AND tabStatus = 'Exception')

UPDATE tblTabCount
SET newordersfailed = (SELECT COUNT(customerid)
						FROM tblOrders
						WHERE orderno IN (SELECT orderno
											FROM tblreviewedfailedorders
											WHERE orderno IS NOT NULL)
						AND orderStatus = 'Failed')

--left off here on cleanup on 10/24/18, jf

UPDATE tblTabCount
SET ordersallvalid = (SELECT COUNT(orderID) AS numRecords
					FROM tblOrders a
					JOIN tblCustomers c
					ON a.customerid = c.customerid
					JOIN tblCustomers_shippingaddress s
					ON a.orderno = s.orderno
					WHERE orderStatus <> 'ACTMIG'
					AND orderStatus <> 'MIGZ'
					AND orderStatus <> 'ADHMIG'
					AND archived = 0)

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--// HOM
--// PART ONE (LOWER TABS)
UPDATE tblTabCount
SET ordershominhouse = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In House')

UPDATE tblTabCount
SET ordershominart = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Art'
OR archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'Waiting for New Art'
OR archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'Waiting On Customer'
OR archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Art for Changes')

UPDATE tblTabCount
SET ordershominpro = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Production')

UPDATE tblTabCount
SET ordershomgtg = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'Good To Go'
OR archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND
orderStatus = 'GTG-Waiting for Payment')

UPDATE tblTabCount
SET ordershomwfp = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'Waiting For Payment')

UPDATE tblTabCount
SET ordershomondock = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus IN ('On HOM Dock','On MRK Dock'))

UPDATE tblTabCount
SET ordershomonproof = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'On Proof')

UPDATE tblTabCount
SET ordershomintrans = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Transit'
OR archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Transit USPS'
OR archived = 0
AND storeid = 2
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND
orderStatus = 'In Transit USPS (Stamped)')

--// PART TWO (HIGHER TABS)	 
UPDATE tblTabCount
SET homnewordersstock = (SELECT COUNT(paymentprocessed)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblOrders.customerid =
tblCustomers.customerid
WHERE orderack = 0
AND archived = 0
AND tblOrders.paymentprocessed = 1
AND tblOrders.paymentsuccessful = 1
AND tabStatus = 'Valid'
AND ordertype = 'Stock'
AND tblCustomers.firstname <> ''
AND orderStatus <> 'Cancelled'
AND orderStatus <> 'Failed'
AND orderStatus <> 'Delivered'
AND orderStatus NOT LIKE '%transit%'
AND storeid = 2)

UPDATE tblTabCount
SET homneworderscustom = (SELECT COUNT(paymentprocessed)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblOrders.customerid =
tblCustomers.customerid
WHERE orderack = 0
AND archived = 0
AND tabStatus <> 'Exception'
AND ordertype = 'Custom'
AND tblOrders.orderStatus <> 'Failed'
AND tblOrders.orderStatus <> 'Cancelled'
AND orderStatus <> 'Delivered'
AND orderStatus NOT LIKE '%transit%'
AND tblCustomers.firstname <> ''
AND storeid = 2)

UPDATE tblTabCount
SET homneworderswaiting = (SELECT COUNT(paymentprocessed)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblOrders.customerid =
tblCustomers.customerid
WHERE archived = 0
AND storeid = 2
AND tblOrders.paymentsuccessful = 0
AND ( tabStatus = 'Offline'
OR tabStatus = 'Faxed'
OR tabStatus = 'CheckCash' )
AND tblOrders.orderStatus <> 'Failed'
AND tblOrders.orderStatus <>
'Cancelled'
AND tblCustomers.firstname <> '')

UPDATE tblTabCount
SET homnewordersexcept = (SELECT COUNT(paymentprocessed)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblOrders.customerid =
tblCustomers.customerid
WHERE archived = 0
AND storeid = 2
AND tblOrders.tabStatus = 'Exception'
AND tblCustomers.firstname <> '')

UPDATE tblTabCount
SET homnewordersfailed = (SELECT COUNT(tblOrders.customerid)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblCustomers.customerid =
tblOrders.customerid
WHERE
orderno IN (SELECT orderno
FROM tblreviewedfailedorders
WHERE orderno IS NOT NULL)
AND orderStatus = 'Failed'
AND storeid = 2)

UPDATE tblTabCount
SET ordershomvalid = (SELECT COUNT(orderID) AS numRecords
FROM tblOrders a
JOIN tblCustomers c
ON a.customerid = c.customerid
JOIN tblCustomers_shippingaddress s
ON a.orderno = s.orderno
WHERE orderStatus <> 'ACTMIG'
AND orderStatus <> 'MIGZ'
AND orderStatus <> 'ADHMIG'
AND archived = 0
AND storeid = 2)

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--// NCC
--//PART ONE
UPDATE tblTabCount
SET ordersnccinhouse = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In House')

UPDATE tblTabCount
SET ordersnccinart = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Art'
OR archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'Waiting for New Art'
OR archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'Waiting On Customer'
OR archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Art for Changes')

UPDATE tblTabCount
SET ordersnccinpro = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Production')

UPDATE tblTabCount
SET ordersnccgtg = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'Good To Go'
OR archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND
orderStatus = 'GTG-Waiting for Payment')

UPDATE tblTabCount
SET ordersnccwfp = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'Waiting For Payment')

UPDATE tblTabCount
SET ordersnccondock = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'On NCC Dock')

UPDATE tblTabCount
SET ordersncconproof = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'On Proof')

UPDATE tblTabCount
SET ordersnccintrans = (SELECT COUNT(orderID)
FROM tblOrders
WHERE archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Transit'
OR archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND orderStatus = 'In Transit USPS'
OR archived = 0
AND storeid = 4
AND orderID IS NOT NULL
AND tabStatus <> 'Failed'
AND
orderStatus = 'In Transit USPS (Stamped)')

--// PART TWO (HIGHER TABS)	 
UPDATE tblTabCount
SET nccnewordersstock = (SELECT COUNT(paymentprocessed)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblOrders.customerid =
tblCustomers.customerid
WHERE orderack = 0
AND archived = 0
AND tblOrders.paymentprocessed = 1
AND tblOrders.paymentsuccessful = 1
AND tabStatus = 'Valid'
AND ordertype = 'Stock'
AND tblCustomers.firstname <> ''
AND orderStatus <> 'Cancelled'
AND orderStatus <> 'Failed'
AND orderStatus <> 'Delivered'
AND orderStatus NOT LIKE '%transit%'
AND storeid = 4)

UPDATE tblTabCount
SET nccneworderscustom = (SELECT COUNT(paymentprocessed)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblOrders.customerid =
tblCustomers.customerid
WHERE orderack = 0
AND archived = 0
AND tabStatus <> 'Exception'
AND ordertype = 'Custom'
AND tblOrders.orderStatus <> 'Failed'
AND tblOrders.orderStatus <> 'Cancelled'
AND orderStatus <> 'Delivered'
AND orderStatus NOT LIKE '%transit%'
AND tblCustomers.firstname <> ''
AND storeid = 4)

UPDATE tblTabCount
SET nccneworderswaiting = (SELECT COUNT(paymentprocessed)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblOrders.customerid =
tblCustomers.customerid
WHERE archived = 0
AND storeid = 4
AND tblOrders.paymentsuccessful = 0
AND ( tabStatus = 'Offline'
OR tabStatus = 'Faxed'
OR tabStatus = 'CheckCash' )
AND tblOrders.orderStatus <> 'Failed'
AND tblOrders.orderStatus <>
'Cancelled'
AND tblCustomers.firstname <> '')

UPDATE tblTabCount
SET nccnewordersexcept = (SELECT COUNT(paymentprocessed)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblOrders.customerid =
tblCustomers.customerid
WHERE archived = 0
AND storeid = 4
AND tblOrders.tabStatus = 'Exception'
AND tblCustomers.firstname <> '')

UPDATE tblTabCount
SET nccnewordersfailed = (SELECT COUNT(tblOrders.customerid)
FROM tblOrders
LEFT JOIN tblCustomers
ON tblCustomers.customerid =
tblOrders.customerid
WHERE
orderno IN (SELECT orderno
FROM tblreviewedfailedorders
WHERE orderno IS NOT NULL)
AND orderStatus = 'Failed'
AND storeid = 4)

UPDATE tblTabCount
SET ordersnccvalid = (SELECT COUNT(orderID) AS numRecords
FROM tblOrders a
JOIN tblCustomers c
ON a.customerid = c.customerid
JOIN tblCustomers_shippingaddress s
ON a.orderno = s.orderno
WHERE orderStatus <> 'ACTMIG'
AND orderStatus <> 'MIGZ'
AND orderStatus <> 'ADHMIG'
AND archived = 0
AND storeid = 4)