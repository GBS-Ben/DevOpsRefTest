CREATE PROC [dbo].[usp_getBadges_customFlow]
AS

-- 1. remove invalid records
DELETE FROM tblBadges_customFlow
WHERE ordersProductsID IN
	(SELECT DISTINCT ordersProductsID
	FROM tblOrders_Products
	WHERE switch_create = 1
	AND ordersProductsID IS NOT NULL)

-- 2. insert new records
INSERT INTO tblBadges_customFlow (orderID, orderNo, ordersProductsID, insertDate)
SELECT a.orderID, a.orderNo,
b.ID,
GETDATE()
FROM tblOrders a
JOIN tblOrders_Products b
	ON a.orderID = b.orderID
WHERE
a.orderStatus <> 'cancelled' 
AND a.orderStatus <> 'failed' 
AND a.orderStatus <> 'delivered'
AND a.orderStatus <> 'In Transit' 
AND a.orderStatus <> 'MIGZ'
--AND a.displayPaymentStatus = 'Good'
AND b.ID NOT IN
	(SELECT DISTINCT ordersProductsID
	FROM tblBadges_customFlow
	WHERE ordersProductsID IS NOT NULL)
AND b.productCode = 'NB00SU-001'
AND b.deleteX <> 'yes'
AND b.switch_create = 0

-- 3. update fields
UPDATE tblBadges_customFlow
SET lineCount = REPLACE(REPLACE(REPLACE(REPLACE(p.textValue, ',' , ''), 'Lines', ''), 'Line', ''), ' ', '')
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'Info Line 1:'

UPDATE tblBadges_customFlow
SET backgroundColor = p.textValue
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'Background Color'

UPDATE tblBadges_customFlow
SET textColor = p.textValue
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'Text Color'

UPDATE tblBadges_customFlow
SET frameColor = p.optionCaption
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionGroupCaption = 'Frame'

UPDATE tblBadges_customFlow
SET shape = p.optionCaption
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionGroupCaption = 'Shape'

UPDATE tblBadges_customFlow
SET artInstructions = p.textValue
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'Art Instructions'

UPDATE tblBadges_customFlow
SET logo1 = RIGHT(p.textValue, CHARINDEX('/',REVERSE(p.textValue))-1)
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'File Name 1'

UPDATE tblBadges_customFlow
SET logo2 = RIGHT(p.textValue, CHARINDEX('/',REVERSE(p.textValue))-1)
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'File Name 2'

UPDATE tblBadges_customFlow
SET logo3 = RIGHT(p.textValue, CHARINDEX('/',REVERSE(p.textValue))-1)
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'File Name 3'

UPDATE tblBadges_customFlow
SET logo4 = RIGHT(p.textValue, CHARINDEX('/',REVERSE(p.textValue))-1)
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'File Name 4'

UPDATE tblBadges_customFlow
SET logo5 = RIGHT(p.textValue, CHARINDEX('/',REVERSE(p.textValue))-1)
FROM tblBadges_customFlow a
JOIN tblOrdersProducts_productOptions p
	ON a.ordersProductsID = p.ordersProductsID
WHERE p.optionCaption = 'File Name 5'

-- 4. retrieve data
SELECT * FROM tblBadges_customFlow