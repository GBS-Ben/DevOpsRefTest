--04/27/2021		CKB, Markful



CREATE  PROC [dbo].[GetSome] @orderNo VARCHAR(20)
AS

DECLARE @OPID VARCHAR(20)

IF LEN(@orderNo) = 6
BEGIN
	SET @orderNo = 'HOM' + @orderNo
END

IF LEN(@orderNo) = 7
BEGIN
	SET @orderNo = 'MRK' + @orderNo
END

IF SUBSTRING(@orderNo, 1, 1) IN ('2', '4', '5', '6')
BEGIN
	SET @OPID = @orderNo
	SET @orderNo = NULL
END

IF @OPID IS NOT NULL
BEGIN
	SET @orderNo = (SELECT orderNo
					FROM tblOrders o
					INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
					WHERE op.ID = @OPID)
END

DECLARE @orderID INT,
		@offset INT

SET @orderID = (SELECT TOP 1 orderID
				FROM tblOrders
				WHERE orderNo = @orderNo)

EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @Offset OUTPUT

--LOCAL
SELECT 'Local - tblOrders' AS tblOrders, o.*
FROM tblOrders o
WHERE orderNo = @orderNo

SELECT 'Local - tblOrders_Products' AS tblOrders_Products, op.*
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderNo = @orderNo AND (@OPID IS NULL OR @OPID = op.ID)

SELECT 'Local - OPPO' AS tblOrdersProducts_productOptions, oppo.*
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo ON op.ID = oppo.ordersProductsID
WHERE o.orderNo = @orderNo  AND (@OPID IS NULL OR @OPID = op.ID)
order by oppo.ordersProductsID,oppo.deletex,oppo.modified_on

SELECT 'Local - tblCustomers' AS tblCustomers, c.*
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderNo = @orderNo

SELECT 'Local - tblCustomers_ShippingAddress' AS tblCustomers_ShippingAddress, c.*
FROM tblCustomers_ShippingAddress c
WHERE c.orderNo = @orderNo

SELECT 'Local - tblCustomers_BillingAddress' AS tblCustomers_BillingAddress, b.*
FROM tblCustomers_BillingAddress b
WHERE b.orderNo = @orderNo

SELECT 'Local - tblOrderView' AS tblOrderView, x.*
FROM tblOrders x
WHERE x.orderNo = @orderNo

--NOP
SELECT 'NOP - Order' AS 'NopOrder', *
FROM dbo.[nopCommerce_order] 
WHERE ID = @OrderID - @offset

SELECT 'NOP - Product' AS 'NopProduct', x.*
,y.Id as OrderItem_ID
,y.OrderItemGuid
,y.OrderId
,y.ProductId
,y.Quantity
,y.UnitPriceInclTax
,y.UnitPriceExclTax
,y.PriceInclTax
,y.PriceExclTax
,y.DiscountAmountInclTax
,y.DiscountAmountExclTax
,y.OriginalProductCost
,y.AttributeDescription
,y.AttributesXml
,y.DownloadCount
,y.IsDownloadActivated
,y.LicenseDownloadId
,y.ItemWeight
,y.RentalStartDateUtc
,y.RentalEndDateUtc

FROM dbo.nopCommerce_product x
INNER JOIN dbo.nopCommerce_orderItem y ON x.ID = y.ProductID
WHERE y.orderID = @OrderID - @offset

SELECT 'NOP - OrderItem' AS 'Nop OrderItem', *
FROM dbo.nopCommerce_orderitem
WHERE OrderID = @OrderID - @offset

SELECT 'NOP - tblNopOrderItem' AS 'Nop tblNopOrderItem', *
FROM dbo.nopCommerce_tblnoporderitem
WHERE noporderitemid = @OPID - @offset



SELECT 'NOP - Customer' AS 'NopCustomer', c.*
FROM dbo.nopCommerce_customer c
INNER JOIN dbo.nopCommerce_order o ON o.CustomerID = c.ID
WHERE o.ID = @OrderID - @offset 

SELECT 'NOP - Billing Address' AS 'NopBillingAddress', a.*
FROM dbo.nopCommerce_address a
INNER JOIN dbo.nopCommerce_customer c ON c.BillingAddress_ID = a.ID
INNER JOIN dbo.nopCommerce_order o ON o.CustomerID = c.ID
WHERE o.ID = @OrderID - @offset 

SELECT 'NOP - Shipping Address' AS 'NopShippingAddress', a.*
FROM dbo.nopCommerce_address a
INNER JOIN dbo.nopCommerce_customer c ON c.ShippingAddress_ID = a.ID
INNER JOIN dbo.nopCommerce_order o ON o.CustomerID = c.ID
WHERE o.ID = @OrderID - @offset 


SELECT DISTINCT 'Local - tblProducts' AS tblProducts, p.*
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo ON op.ID = oppo.ordersProductsID
INNER JOIN tblProducts p ON op.productID = p.productID
WHERE o.orderNo = @orderNo 

SELECT 'Local - tblSwitch_pUnit_TRON' AS tblSwitch_pUnit_TRON, t.*
FROM tblSwitch_pUnit_TRON t
WHERE t.orderNo = @orderNo

SELECT 'Local - tblChaseTransactions' AS tblChaseTransactions, t.*
FROM tblChaseTransactions t
WHERE t.orderNo = @orderNo

SELECT 'Local - tblTransactions' AS tblTransactions, t.*
FROM tblTransactions t
WHERE t.orderNo = @orderNo

SELECT 'Local - tblOPPO_fileExists' AS tblOPPO_fileExists, u.*
FROM tblOPPO_fileExists u
WHERE u.OPID = @OPID

SELECT 'Local - FileDownloadLog' AS FileDownloadLog, n.*
FROM FileDownloadLog n
WHERE n.OrdersProductsId = @OPID

SELECT 'Local - tblNopProductionFiles' AS tblNopProductionFiles, n.*
FROM tblNOPProductionFiles n
WHERE n.nopOrderItemID = @OPID

SELECT 'Local - impolog' As impolog, i.*
From impolog i
WHERE i.opid = @OPID

SELECT 'Local - tblswitchBatchLog' As tblSwitchBatchLog, sbl.*
From tblSwitchBatchLog sbl
WHERE sbl.ordersProductsID = @OPID

SELECT 'Local - tblswitchReportLog' As tblSwitchReportLog, srl.*
from tblswitchReportLog srl
WHERE srl.ordersProductsID = @OPID