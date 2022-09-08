


CREATE PROC [dbo].[usp_TicTic_ShipsWith]
@OPID int,
@flowname varchar(10)
AS
BEGIN TRY
	DECLARE @json NVARCHAR(max),@retjson NVARCHAR(max),@rc INT
	SET @json = (SELECT orderid,@flowName as switchflow from tblOrders_Products WHERE id = @OPID FOR JSON PATH);
	EXECUTE @RC = [dbo].[GetShipsWith] 
	   @json
	  ,@retJson OUTPUT

	DROP TABLE IF EXISTS #tmpShip
	SELECT   orderID
			,customProductCount
			,customProductCode1
			,customProductCode2
			,customProductCode3
			,customProductCode4
			,fasTrakProductCount
			,fasTrakProductCode1
			,fasTrakProductCode2
			,fasTrakProductCode3
			,fasTrakProductCode4
			,stockProductCount
			,stockProductCode1
			,stockProductDescription1
			,stockProductQuantity1
			,stockProductCode2
			,stockProductDescription2
			,stockProductQuantity2
			,stockProductCode3
			,stockProductDescription3
			,stockProductQuantity3
			,stockProductCode4
			,stockProductDescription4
			,stockProductQuantity4
			,stockProductCode5
			,stockProductDescription5
			,stockProductQuantity5
			,stockProductCode6
			,stockProductDescription6
			,stockProductQuantity6
		INTO #tmpShip
			FROM OPENJSON(@retJson)
			WITH  (		orderID int '$.orderID',
			CustomProductCount int '$.CustomProductCount',
			customProductCode1 varchar(255) '$.customProductCode1',
			customProductCode2 varchar(255) '$.customProductCode2',
			customProductCode3 varchar(255) '$.customProductCode3',
			customProductCode4 varchar(255) '$.customProductCode4',
			FasTrakProductCount int '$.FasTrakProductCount',
			FasTrakProductCode1 varchar(255) '$.FasTrakProductCode1',
			FasTrakProductCode2 varchar(255) '$.FasTrakProductCode2',
			FasTrakProductCode3 varchar(255) '$.FasTrakProductCode3',
			FasTrakProductCode4 varchar(255) '$.FasTrakProductCode4',
			StockProductCount int '$.StockProductCount',
			StockProductCode1 varchar(255) '$.StockProductCode1',
			StockProductDescription1 varchar(255) '$.StockProductDescription1',
			StockProductQuantity1 varchar(255) '$.StockProductQuantity1',
			StockProductCode2 varchar(255) '$.StockProductCode2',
			StockProductDescription2 varchar(255) '$.StockProductDescription2',
			StockProductQuantity2 varchar(255) '$.StockProductQuantity2',
			StockProductCode3 varchar(255) '$.StockProductCode3',
			StockProductDescription3 varchar(255) '$.StockProductDescription3',
			StockProductQuantity3 varchar(255) '$.StockProductQuantity3',
			StockProductCode4 varchar(255) '$.StockProductCode4',
			StockProductDescription4 varchar(255) '$.StockProductDescription4',
			StockProductQuantity4 varchar(255) '$.StockProductQuantity4',
			StockProductCode5 varchar(255) '$.StockProductCode5',
			StockProductDescription5 varchar(255) '$.StockProductDescription5',
			StockProductQuantity5 varchar(255) '$.StockProductQuantity5',
			StockProductCode6 varchar(255) '$.StockProductCode6',
			StockProductDescription6 varchar(255) '$.StockProductDescription6',
			StockProductQuantity6 varchar(255) '$.StockProductQuantity6')

	 SELECT 
		 t.orderID
		,@OPID as OPID
		,customProductCount
		,customProductCode1
		,customProductCode2
		,customProductCode3
		,customProductCode4
		,fasTrakProductCount
		,fasTrakProductCode1
		,fasTrakProductCode2
		,fasTrakProductCode3
		,fasTrakProductCode4
		,stockProductCount
		,stockProductCode1
		,stockProductDescription1
		,stockProductQuantity1
		,stockProductCode2
		,stockProductDescription2
		,stockProductQuantity2
		,stockProductCode3
		,stockProductDescription3
		,stockProductQuantity3
		,stockProductCode4
		,stockProductDescription4
		,stockProductQuantity4
		,stockProductCode5
		,stockProductDescription5
		,stockProductQuantity5
		,stockProductCode6
		,stockProductDescription6
		,stockProductQuantity6
		,shipsWith = CASE WHEN o.orderID IS NOT NULL THEN 'LOCAL PICKUP'
						  WHEN t.CustomProductCount > 0  THEN 'CUSTOM'
						  WHEN t.FasTrakProductCount > 0 THEN 'FASTRAK'
						  WHEN t.StockProductCount > 0 THEN 'STOCK'
				 		  ELSE 'SHIP' END
		,shipsWithColor = CASE WHEN o.orderID IS NOT NULL THEN '#4712ff' -- purple
						  WHEN t.CustomProductCount > 0  THEN '#fa6917'  --orange
						  WHEN t.FasTrakProductCount > 0 THEN '#840911'--maroon
						  WHEN t.StockProductCount > 0 THEN '#003399'--blue
				 		  ELSE '#19941B' END --green
		,shipType = CASE WHEN CONVERT(VARCHAR(255), o2.shippingDesc) LIKE '%3%' THEN '3 Day'
						 WHEN  CONVERT(VARCHAR(255), o2.shippingDesc) LIKE '%2%' THEN '2 Day'
						 WHEN  CONVERT(VARCHAR(255), o2.shippingDesc) LIKE '%next%' THEN 'Next Day'
						 WHEN  o.orderID IS NOT NULL THEN 'Local Pickup'
						 ELSE 'Ship' END
		,arrivalDate = ISNULL(LEFT(' | Arrive by ' + CONVERT(NVARCHAR(50), DATEPART(MM, a.arrivalDate)) + '/' + CONVERT(NVARCHAR(50), DATEPART(DD, a.arrivalDate)), 50),'')
	FROM #tmpShip t
	INNER JOIN tblOrders a on t.orderid = a.orderid
	LEFT JOIN tblOrders o ON t.orderid = o.orderid AND 	(  CONVERT(VARCHAR(255), o.shippingDesc) LIKE '%local%' 
															OR CONVERT(VARCHAR(255), o.shippingDesc) LIKE '%will call%'
															OR CONVERT(VARCHAR(255), o.shipping_firstName) LIKE '%local%')
	LEFT JOIN tblOrders o2 ON t.orderid = o2.orderid and (CONVERT(VARCHAR(255), o2.shippingDesc) LIKE '%3%' 
														  OR CONVERT(VARCHAR(255), o2.shippingDesc) LIKE '%2%' 
														  OR CONVERT(VARCHAR(255), o2.shippingDesc) LIKE '%next%' )
END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXECUTE [dbo].[usp_StoredProcedureErrorLog]

END CATCH
GO
