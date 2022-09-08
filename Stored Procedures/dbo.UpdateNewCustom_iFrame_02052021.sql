CREATE PROC [dbo].[UpdateNewCustom_iFrame_02052021]
@tab VARCHAR(255) ,--='New-Apparel',
@orderID INT --= 555656852

AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     11/01/2020
Purpose     Updates values on the Intranet here: http://sbs/gbs/admin/ordersNewCustom88.asp
Related		EXEC GetNewCustom
-------------------------------------------------------------------------------------
Modification History

11/01/2020	JF, created.
11/16/2020	JF, updated MISC to join on OPID

-------------------------------------------------------------------------------------
*/
-- set OPID-level isPrinted bits to prevent future processing

INSERT INTO JFTEST(TEST, submitDate) SELECT 'hello', getdate()

IF @tab = 'New-Signs'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'SN%' 
	AND op.processType = 'Custom' 
END

IF @tab = 'New-Masks'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'MK%' 
	AND op.processType = 'Custom' 
END

IF @tab = 'New-Nameplates'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'PL%' 
	AND op.processType = 'Custom' 
END

IF @tab = 'New-Inserts'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND ((SUBSTRING(op.productCode, 3, 2) = 'IN' OR op.productCode LIKE 'LPG%') AND op.productName LIKE '%insert%')
	AND op.processType = 'Custom' 
END

IF @tab = 'New-WFP'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND o.orderStatus = 'Waiting For Payment'
	AND op.processType = 'Custom' 
END

IF @tab = 'New-Apparel'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'AP%' 
	AND op.processType = 'Custom'
END

IF @tab = 'New-BC-Lux'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'BP%' 
	AND op.processType = 'Custom'
	AND EXISTS
		(SELECT TOP 1 1
		FROM tblOrdersProducts_productOptions oppx
		WHERE oppx.deleteX <> 'yes'
		AND oppx.optionID IN (573, 574, 575)
		AND op.ID = oppx.ordersProductsID)
END

IF @tab = 'New-Envelopes'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND ((SUBSTRING(op.productCode, 1, 2) = 'EV' OR SUBSTRING(op.productCode, 3, 2) = 'EV') AND op.productName LIKE '%envelope%' 
			 OR SUBSTRING(op.productCode, 1, 2) = 'LH')
	AND op.processType = 'Custom'
END

IF @tab = 'New-Misc'
BEGIN
	UPDATE op
	SET isPrinted = 1
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.orderID = @orderID
	AND op.deleteX <> 'yes' 
	AND op.processType = 'Custom'
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xx
		WHERE xx.deleteX <> 'yes'
		AND (
				--Signs, Apparel, Letterhead, Platenames, Masks, Gaiters
				SUBSTRING(xx.productCode, 1, 2) IN ('SN', 'AP', 'LH', 'PL', 'MK')
				
				--Envelopes
				OR ((SUBSTRING(xx.productCode, 1, 2) = 'EV' OR SUBSTRING(xx.productCode, 3, 2) = 'EV') AND xx.productName LIKE '%envelope%' )
				
				--Inserts
				OR ((SUBSTRING(xx.productCode, 3, 2) = 'IN' OR xx.productCode LIKE 'LPG%') AND xx.productName LIKE '%insert%')

				--Business Cards - Lux
				OR (SUBSTRING(xx.productCode, 1, 2) = 'BP'
						AND EXISTS
									(SELECT TOP 1 1
									FROM tblOrdersProducts_productOptions oppx
									WHERE oppx.deleteX <> 'yes'
									AND oppx.optionID IN (573, 574, 575)
									AND xx.ID = oppx.ordersProductsID)
						)
				  )
		AND xx.processType = 'Custom'
		AND op.ID = xx.ID)
END

-- if all custom OPIDs in @orderID have tblOrders_Products.isPrinted = 1
-- then set order as acknowledged

UPDATE o
SET orderAck = 1, orderForPrint = 1, orderBatchedDate = GETDATE()
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderID = @orderID
AND o.orderType = 'Custom' 
AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xx
		WHERE xx.deleteX <> 'yes'
		AND xx.processType = 'Custom'
		AND xx.isPrinted = 0
		AND op.orderID = xx.orderID)