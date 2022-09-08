CREATE PROC [dbo].[GetNewCustom_111821] 
@tab VARCHAR(255) = ''
AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     11/01/2020
Purpose     Provides values on the Intranet here: http://sbs/gbs/admin/ordersNewCustom88.asp
Related		EXEC UpdateNewCustom; ordersNewCustom88.asp; admin88.asp; orderBatchPrintJT88.asp
-------------------------------------------------------------------------------------
Modification History

11/01/2020	JF, created.
11/16/2020	JF, updated MISC to join on orderID
12/08/2020	CKB, iFrame conversion changes
02/10/2021  CKB, fixed 32pt and 52pt wildcards
04/27/2021  CKB, Markful
09/01/2021	JF, Added ULYA section and ULYA NOT EXISTS for the MISC Tab.
10/18/2021	JF, Added additional logic to the suppression of Shaped Name Badges in the MISC tab.
10/18/2021	JF, Added Pens. Added Custom Art.
10/20/2021	JF, Fixed Custom Art EXISTS statements.
11/10/2021	CKB, split apparel
-------------------------------------------------------------------------------------
*/
IF @tab = ''
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 0 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	ORDER BY o.orderDate DESC
END

-- Begin OrderStatus centric views ----------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

IF @tab = 'In House'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

IF @tab = 'In Art'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

IF @tab = 'On Proof'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

IF @tab = 'Good To Go'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

IF @tab = 'In Production'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

IF @tab = 'On HOM Dock' OR @tab = 'On MRK Dock'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

IF @tab = 'In Transit'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

IF @tab = 'In Transit USPS'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

IF @tab = 'Delivered'
BEGIN
	SELECT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	WHERE o.archived = 0 
	AND o.orderAck = 1 
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS')
	AND o.orderStatus = @tab
	ORDER BY o.orderDate DESC
END

-- Begin OPID centric views ------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

IF @tab = 'New-Signs'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'SN%' 
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-Apparel'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'AP%' 
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

--IF @tab = 'New-Apparel'
--BEGIN

--	SELECT DISTINCT orderID, customerID, orderDate, orderNo, orderTotal, paymentAmountRequired, 
--	paymentMethod, orderStatus, statusDate, lastStatusUpdate, orderType,shippingMethod,
--	shippingDesc, storeID, firstName, surname, NOP 
--	FROM vwCustomApparelOrders cd 
--	WHERE digitized = 1 AND orderno NOT IN (SELECT orderno FROM vwCustomApparelOrders WHERE digitized = 0)
--	ORDER BY orderDate DESC

--END

--IF @tab = 'New-Apparel-Digitize'
--BEGIN

--	SELECT DISTINCT orderID, customerID, orderDate, orderNo, orderTotal, paymentAmountRequired, 
--	paymentMethod, orderStatus, statusDate, lastStatusUpdate, orderType,shippingMethod,
--	shippingDesc, storeID, firstName, surname, NOP 
--	FROM vwCustomApparelOrders cd 
--	WHERE digitized =  0
--	ORDER BY orderDate DESC
--END

IF @tab = 'New-BC-Lux'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'BP%' 
	AND op.processType = 'Custom'
	AND EXISTS
		(SELECT TOP 1 1
		FROM tblOrdersProducts_productOptions oppx
		WHERE oppx.deleteX <> 'yes'
		AND (oppx.optionID IN (573, 574, 575)
			OR (oppx.optionCaption='Paper Stock' and (oppx.textValue like '%32%pt%' or oppx.textValue like '%52%pt%'))	-- added iFrame conversion options
			)
		AND op.ID = oppx.ordersProductsID)
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-Masks'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'MK%' 
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-Pens'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'PN%' 
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-Nameplates'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'PL%' 
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-Envelopes'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired,
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0 
	AND op.deleteX <> 'yes' 
	AND ((SUBSTRING(op.productCode, 1, 2) = 'EV' OR SUBSTRING(op.productCode, 3, 2) = 'EV') AND op.productName LIKE '%envelope%' 
			 OR SUBSTRING(op.productCode, 1, 2) = 'LH')
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-Inserts'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND (SUBSTRING(op.productCode, 3, 2) = 'IN' AND op.productName LIKE '%insert%')
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-Custom-Art'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND EXISTS
		(SELECT TOP 1 1
		FROM tblOrders o
		INNER JOIN tblOrders_Products opp
		ON o.orderID = opp.orderID
		INNER JOIN tblOrdersProducts_productOptions oppx ON oppx.ordersproductsID = opp.id
		AND ((oppx.optionCaption IN ('Change Fee', 'Design Fee') AND textValue = 'Yes')
			OR oppx.optionCaption = 'Previous Order Number')
		AND op.id = oppx.ordersProductsID)
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-Shaped-Badges'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.productCode LIKE 'NB__S%'  --shaped
	AND op.productCode NOT LIKE 'NB___U%'  --not 'setup'
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-ULYA'
BEGIN

	-- FAs
	SELECT DISTINCT
	o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod, 
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
	WHERE o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND op.deleteX <> 'yes'
	AND oppx.deleteX <> 'yes'
	AND op.fastTrak_status = 'In House'
	AND	(op.productcode like '__FA%' OR op.productCode lIKE 'FA%')
	AND NOT EXISTS (SELECT top 1 1 
					FROM tblOrdersProducts_ProductOptions oppo WHERE oppo.ordersProductsID = op.Id
					AND DeleteX <> 'yes'
					AND optionID IN (641,374,373,21, 586, 702))
	--ALT Js
	UNION
	SELECT DISTINCT
	o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod, 
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
	WHERE o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND op.deleteX <> 'yes'
	AND oppx.deleteX <> 'yes'
	AND op.fastTrak_status = 'In House'
	AND RIGHT(oppx.textValue, 2) = '_J'
	AND NOT EXISTS (SELECT top 1 1 
					FROM tblOrdersProducts_ProductOptions oppo WHERE oppo.ordersProductsID = op.Id
					AND DeleteX <> 'yes'
					AND optionID IN (641,374,373,21, 586, 702)) --exclude fees and previous orders			
	ORDER BY orderDate DESC, orderStatus
END

IF @tab = 'New-Misc'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND op.processType = 'Custom'
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 

	--Signs, Apparel, Letterhead, Platenames, Masks, Gaiters, Pens
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xx
		WHERE xx.deleteX <> 'yes'
		AND SUBSTRING(xx.productCode, 1, 2) IN ('SN', 'AP', 'LH', 'PL', 'MK', 'PN')
		AND xx.processType = 'Custom'
		AND op.ID = xx.ID)

	--Envelopes
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xxy
		WHERE xxy.deleteX <> 'yes'
		AND (SUBSTRING(xxy.productCode, 1, 2) = 'EV' OR SUBSTRING(xxy.productCode, 3, 2) = 'EV') 
		AND xxy.productName LIKE '%envelope%'
		AND xxy.processType = 'Custom'
		AND op.ID = xxy.ID)

	--Inserts
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xxb
		WHERE xxb.deleteX <> 'yes'
		AND SUBSTRING(xxb.productCode, 3, 2) = 'IN' 
		AND xxb.productName LIKE '%insert%'
		AND xxb.processType = 'Custom'
		AND op.ID = xxb.ID)

	--Custom Art
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders oy
		LEFT JOIN tblCustomers cy ON oy.customerID = cy.customerID 
		INNER JOIN tblOrders_Products opy ON oy.orderID = opy.orderID
		WHERE oy.archived = 0 
		AND opy.isPrinted = 0
		AND oy.tabStatus NOT IN ('Failed', 'Exception')
		AND oy.orderType = 'Custom' 
		AND oy.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
		AND oy.orderAck = 0
		AND opy.deleteX <> 'yes' 
		AND EXISTS
			(SELECT TOP 1 1
			FROM tblOrders oyy
			INNER JOIN tblOrders_Products oppyy
			ON oyy.orderID = oppyy.orderID
			INNER JOIN tblOrdersProducts_productOptions oppxyy ON oppxyy.ordersproductsID = oppyy.id
			AND ((oppxyy.optionCaption IN ('Change Fee', 'Design Fee') AND textValue = 'Yes')
				OR oppxyy.optionCaption = 'Previous Order Number')
			AND opy.id = oppxyy.ordersProductsID)
		AND opy.processType = 'Custom'
		AND op.ID = opy.ID)	

	--Shaped Badges
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xxbb
		WHERE xxbb.deleteX <> 'yes' 
		AND xxbb.productCode LIKE 'NB__S%'  --shaped
		AND xxbb.productCode NOT LIKE 'NB___U%'  --not 'setup'
		AND xxbb.processType = 'Custom'
		AND op.ID = xxbb.ID)

	--Business Cards - Lux
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xxm
		WHERE xxm.deleteX <> 'yes'
		AND SUBSTRING(xxm.productCode, 1, 2) = 'BP'
						AND EXISTS
							(SELECT TOP 1 1
							FROM tblOrdersProducts_productOptions oppx
							WHERE oppx.deleteX <> 'yes'
							AND (oppx.optionID IN (573, 574, 575)
								OR (oppx.optionCaption='Paper Stock' and (oppx.textValue like '%32%pt%' or oppx.textValue like '%52%pt%'))	-- added iFrame conversion options
								)
							AND xxm.ID = oppx.ordersProductsID)
		AND xxm.processType = 'Custom'
		AND op.ID = xxm.ID)

	--ULYA
	/*
	AND NOT EXISTS --1/2
		(SELECT TOP 1 1
		FROM tblOrders o 
		LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
		INNER JOIN tblOrders_Products xxq ON o.orderID = xxq.orderID 
		INNER JOIN tblOrdersProducts_productOptions oppx ON xxq.ID = oppx.ordersProductsID 
		WHERE 
		o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment') 
		AND xxq.deleteX <> 'yes' 
		AND oppx.deleteX <> 'yes' 
		AND op.ID = xxq.ID
		AND xxq.fastTrak_status = 'In House' 
		AND (xxq.productcode like '__FA%' OR xxq.productCode lIKE 'FA%') 
		AND NOT EXISTS 
			(SELECT top 1 1 
			FROM tblOrdersProducts_ProductOptions oppo 
			WHERE oppo.ordersProductsID = xxq.Id 
			AND DeleteX <> 'yes' 
			AND optionID IN (641,374,373,21, 586, 702)))

	AND NOT EXISTS --2/2
		(SELECT TOP 1 1
		FROM tblOrders o 
		LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
		INNER JOIN tblOrders_Products xxq ON o.orderID = xxq.orderID 
		INNER JOIN tblOrdersProducts_productOptions oppx ON xxq.ID = oppx.ordersProductsID 
		WHERE o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment') 
		AND xxq.deleteX <> 'yes' 
		AND oppx.deleteX <> 'yes' 
		AND op.ID = xxq.ID
		AND xxq.fastTrak_status = 'In House' 
		AND RIGHT(oppx.textValue, 2) = '_J' 
		AND NOT EXISTS 
			(SELECT top 1 1 
			FROM tblOrdersProducts_ProductOptions oppo 
			WHERE oppo.ordersProductsID = xxq.Id 
			AND DeleteX <> 'yes' 
			AND optionID IN (641,374,373,21, 586, 702)))
	*/
	ORDER BY o.orderDate DESC
END

IF @tab = 'New-WFP'
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	WHERE o.archived = 0 
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus = 'Waiting For Payment'
	AND o.orderAck = 0
	AND op.deleteX <> 'yes' 
	AND op.processType = 'Custom'
	ORDER BY o.orderDate DESC
END