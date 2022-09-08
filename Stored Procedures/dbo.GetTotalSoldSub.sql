-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- 04/27/2021		CKB, Markful
-- =============================================

CREATE PROCEDURE [dbo].[GetTotalSoldSub]

	@From nvarchar(25),
	@To nvarchar(25),
	@ProductID int,
	@Param nvarchar(50)
	--@CountRow INT OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
	if @Param='total'
	begin
	
SELECT DISTINCT  o.orderID, o.orderNo, c.firstName, c.surName, o.customerID, p.productQuantity, o.orderTotal, o.orderDate, o.orderStatus, a.numunits
   FROM       tblOrders_Products p JOIN tblOrders o on p.orderID=o.orderID JOIN tblProducts a on p.productID=a.productID JOIN tblCustomers c on o.customerID=c.customerID
   WHERE (a.parentProductID = @ProductID or p.productID = @ProductID) AND o.archived=0 AND p.deleteX <> 'Yes' AND (o.orderStatus <> 'Cancelled' AND o.orderStatus <> 'Failed' AND o.orderDate >= @From AND o.orderDate < @To)
END

	else 
		  if @Param='hold'
			begin
SELECT DISTINCT o.orderID, o.orderNo, c.firstName, c.surName, o.customerID, p.productQuantity, o.orderTotal, o.orderDate, o.orderStatus, a.numunits
FROM tblOrders_Products p JOIN tblOrders o on p.orderID=o.orderID JOIN tblProducts a on p.productID=a.productID JOIN tblCustomers c on o.customerID=c.customerID 
WHERE (a.parentProductID = @ProductID  or p.productID = @ProductID ) AND o.paymentProcessed=0 AND o.paymentSuccessful=0 AND p.deleteX <> 'Yes' AND (o.orderStatus like '%waiting for payment%' AND o.orderStatus <> 'Cancelled' AND o.orderStatus <> 'Failed' AND o.orderStatus <> 'On HOM Dock' AND o.orderStatus <> 'On MRK Dock' AND o.orderStatus NOT LIKE '%Transit%' AND o.orderStatus <> 'Delivered') AND orderDate >= @From AND orderDate < @To
			end
else 
		  if @Param='wip'
			begin
SELECT DISTINCT o.orderID, o.orderNo, c.firstName, c.surName, o.customerID, p.productQuantity, o.orderTotal, o.orderDate, o.orderStatus, a.numunits 
FROM tblOrders_Products p JOIN tblOrders o on p.orderID=o.orderID JOIN tblProducts a on p.productID=a.productID JOIN tblCustomers c on o.customerID=c.customerID 
WHERE (a.parentProductID = @ProductID or p.productID = @ProductID) AND p.deleteX <> 'Yes' AND (o.orderStatus not like '%waiting for payment%' AND o.orderStatus <> 'Cancelled' AND o.orderStatus <> 'Failed' AND o.orderStatus <> 'On HOM Dock' AND o.orderStatus <> 'On MRK Dock' AND o.orderStatus NOT LIKE '%Transit%' AND o.orderStatus <> 'Delivered') AND orderDate >= @From AND orderDate < @To
			end
END