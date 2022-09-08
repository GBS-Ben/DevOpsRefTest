CREATE PROC [dbo].[GetShipsWith]
	@orderJson nvarchar(max),
	@retJson nvarchar(max) OUTPUT
AS
SET NOCOUNT ON

/*
-------------------------------------------------------------------------------
Author      Cherilyn Browne
Created     01/23/22
Purpose     Create tic tic ships with info
-------------------------------------------------------------------------------
Modification History

01/23/22	    Created, ckb.
*/
--declare 	@orderJson nvarchar(max)

--set @orderJson = (select orderid,'BC' as switchflow from tblswitch_BCD_thresholddiff_tron for json path)
--SELECT @orderJson
--SELECT  orderID, switchFlow
--				FROM OPENJSON(@orderJson)
--				WITH (orderID int '$.orderid',
--				switchFlow nvarchar(255) '$.switchflow')
BEGIN
	IF OBJECT_ID('tempdb..#cteShipsWith') IS NOT NULL
		drop table  #cteShipsWith;

	WITH cteJson AS (
	SELECT distinct orderID, switchFlow
					FROM OPENJSON(@orderJson)
					WITH (orderID int '$.orderid',
					switchFlow nvarchar(255) '$.switchflow')),
	cteOrders AS (SELECT j.orderId,op.processType,CASE WHEN op.processType = 'stock' then osf.productCode ELSE osf.ProductCategory END AS 'productCategory',CASE WHEN op.processType = 'stock' THEN p.productName ELSE '' END as productName,sum(op.productQuantity) as productQuantity
		FROM cteJson j
		LEFT JOIN opidswitchflow osf ON osf.orderid = j.orderID AND osf.switchFlow <> j.switchFlow AND SUBSTRING(osf.productCode, 1, 2) <> 'PN' AND SUBSTRING(osf.productCode, 3, 2) <> 'EV'
		LEFT JOIN tblProducts p on osf.productCode = p.productCode
		LEFT JOIN tblOrders_Products op on osf.OPID = op.ID  
		WHERE ISNULL(p.productName,'') NOT LIKE '%Mail%' 
		GROUP BY j.orderId,op.processType,CASE WHEN op.processType = 'stock' then osf.productCode ELSE osf.ProductCategory END,CASE WHEN op.processType = 'stock' THEN p.productName ELSE '' END 
	)
	SELECT orderID,processType,productCategory,productName,productQuantity
	,RANK() OVER(PARTITION BY orderID,processType ORDER BY productCategory) AS 'processItem' 
	,COUNT(productCategory) OVER(PARTITION BY orderID,processType) AS 'productCount'
	into #cteShipsWith
	FROM cteOrders


	--SELECT * FROM #cteShipsWith
SET @retJson = (
	SELECT c.orderID
	,ISNULL((SELECT MAX(productCount) FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 1 AND processType = 'Custom'),0) AS 'CustomProductCount'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 1 AND processType = 'Custom'),'') AS 'customProductCode1'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 2 AND processType = 'Custom'),'') AS 'customProductCode2'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 3 AND processType = 'Custom'),'') AS 'customProductCode3'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 4 AND processType = 'Custom'),'') AS 'customProductCode4'
	,ISNULL((SELECT MAX(productCount) FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 1 AND processType = 'FasTrak'),0) AS 'FasTrakProductCount'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 1 AND processType = 'FasTrak'),'') AS 'FasTrakProductCode1'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 2 AND processType = 'FasTrak'),'') AS 'FasTrakProductCode2'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 3 AND processType = 'FasTrak'),'') AS 'FasTrakProductCode3'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 4 AND processType = 'FasTrak'),'') AS 'FasTrakProductCode4'
	,ISNULL((SELECT MAX(productCount) FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 1 AND processType = 'Stock'),0) AS 'StockProductCount'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 1 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductCode1'
	,ISNULL((SELECT productName   FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 1 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductDescription1'
	,ISNULL((SELECT productQuantity FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 1 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductQuantity1'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 2 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductCode2'
	,ISNULL((SELECT productName   FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 2 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductDescription2'
	,ISNULL((SELECT productQuantity FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 2 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductQuantity2'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 3 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductCode3'
	,ISNULL((SELECT productName   FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 3 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductDescription3'
	,ISNULL((SELECT productQuantity FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 3 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductQuantity3'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 4 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductCode4'
	,ISNULL((SELECT productName   FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 4 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductDescription4'
	,ISNULL((SELECT productQuantity FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 4 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductQuantity4'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 5 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductCode5'
	,ISNULL((SELECT productName   FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 5 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductDescription5'
	,ISNULL((SELECT productQuantity FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 5 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductQuantity5'
	,ISNULL((SELECT productCategory FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 6 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductCode6'
	,ISNULL((SELECT productName   FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 6 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductDescription6'
	,ISNULL((SELECT productQuantity FROM #cteShipsWith WHERE  orderId = c.orderID AND processItem = 6 AND processType = 'Stock' AND productCount < 7),'') AS 'StockProductQuantity6'
	FROM #cteShipsWith c
	GROUP BY c.orderID
	FOR JSON PATH, INCLUDE_NULL_VALUES)
END