CREATE PROC [dbo].[usp_getA1Orders]
AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		12/3/15
-- Purpose		SPROC that presents A1 data on http://sbs/gbs/admin/ordersNewA1.asp
-------------------------------------------------------------------------------
-- Modification History
--
-- 12/3/15		Created
-- 08/14/18	JF, added getLabel check to confirm that any order presented on the A1Tab has a label already gen'd.
-------------------------------------------------------------------------------
SET NOCOUNT ON;
BEGIN TRY

	SELECT o.orderID, o.orderNo, o.orderDate, o.storeID, o.customerID, o.orderType,
	o.paymentMethodRDesc, o.orderStatus, o.shippingDesc, 
	o.orderTotal, o.paymentAmountRequired, o.paymentMethod, o.statusDate, o.lastStatusUpdate,
	o.shippingMethod,  cust.firstName, cust.surName, o.NOP --select o.*
	FROM tblOrders o
	INNER JOIN tblCustomers cust
		ON o.customerID = cust.customerID
	INNER JOIN tblShippingLabels l
		ON o.orderNo = l.referenceID
	WHERE o.a1 = 1
	AND o.orderJustPrinted = 0
	--AND l.getLabel = 1
	
	ORDER BY o.orderDate DESC

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH