CREATE PROC [dbo].[GetNewCustom] 
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
01/25/2022  JSB, Added Large Format Logo Setup.
02/09/2022  JSB, Using vwCustomTab88 to find custom tabs, and removing status tabs 
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

ELSE
BEGIN
	SELECT DISTINCT o.orderID, o.customerID, o.orderDate, o.orderNo, o.orderTotal, o.paymentAmountRequired, 
	o.paymentMethod, o.orderStatus, o.statusDate, o.lastStatusUpdate, o.orderType, o.shippingMethod,
	o.shippingDesc, o.storeID, c.firstName, c.surname, o.NOP 
	FROM tblOrders o
	LEFT JOIN tblCustomers c ON o.customerID = c.customerID 
	INNER JOIN vwCustomTab88 ct ON ct.orderID = o.orderID
	WHERE ct.TabSelected = @tab
	ORDER BY o.orderDate DESC
END