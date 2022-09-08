-- =============================================
-- exec dbo.[ReportDaltonWadeBC]

/*
	
*/
-- =============================================
CREATE PROCEDURE [dbo].[ReportDaltonWadeBC]
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @OrderOffset INT; 
	EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;


DROP TABLE IF EXISTS #tempNop

SELECT nop_op.orderID + @OrderOffset AS orderID, nop_p.Name AS productName, nop_p.sku, nop_o.createdOnPst, nop_op.priceInclTax
INTO #tempNop
FROM nopcommerce_Product nop_p 
INNER JOIN nopcommerce_OrderItem nop_op 
	ON nop_op.ProductId= nop_p.ID
INNER JOIN nopcommerce_order nop_o
	ON nop_op.orderID = nop_o.Id
WHERE nop_p.Sku IN ('bpthh1-001-100-01014-gbs101756','bpthh1-001-100-01014-gbs101757')

SELECT o.orderNo
,(o.shipping_firstName + ' ' + o.shipping_Surname) AS Customer_Name
,nop.createdOnPst AS Order_Date
,op.ID AS OPID 
,op.productName AS Product_Name
,nop.sku AS Product_Code
,nop.PriceInclTax AS Cost_of_OPID
FROM #tempNop nop 
INNER JOIN tblOrders_Products op ON op.orderID = nop.orderID
INNER JOIN tblOrders o ON nop.orderID = o.orderID
WHERE nop.sku LIKE op.productCODE + '%'
AND o.orderStatus NOT IN ('Cancelled', 'Failed')
AND op.deletex <> 'yes'
AND op.gbsCompanyID = 'TH-100-01014'

END