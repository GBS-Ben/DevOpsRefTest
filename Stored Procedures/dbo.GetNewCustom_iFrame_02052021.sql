CREATE PROC [dbo].[GetNewCustom_iFrame_02052021] 
@tab VARCHAR(255) = ''
AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     11/01/2020
Purpose     Provides values on the Intranet here: http://sbs/gbs/admin/ordersNewCustom88.asp
Related		EXEC UpdateNewCustom
-------------------------------------------------------------------------------------
Modification History

11/01/2020	JF, created.
11/16/2020	JF, updated MISC to join on orderID


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

IF @tab = 'On HOM Dock'
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
		AND oppx.optionID IN (573, 574, 575)
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

	--Signs, Apparel, Letterhead, Platenames, Masks, Gaiters
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrders_Products xx
		WHERE xx.deleteX <> 'yes'
		AND SUBSTRING(xx.productCode, 1, 2) IN ('SN', 'AP', 'LH', 'PL', 'MK')
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
							AND oppx.optionID IN (573, 574, 575)
							AND xxm.ID = oppx.ordersProductsID)
		AND xxm.processType = 'Custom'
		AND op.ID = xxm.ID)
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