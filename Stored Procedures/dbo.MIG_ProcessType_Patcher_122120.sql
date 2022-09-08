/*
12/17/20	CKB, added try/catch
*/

CREATE PROCEDURE [dbo].[MIG_ProcessType_Patcher_122120]
AS


BEGIN TRY

	INSERT INTO dbo.tblMigLog (migStamp,migTime, migStoredProc) SELECT 'BEG', GETDATE(),'MIG_ProcessType_Patcher'


	--MOVE THESE TO A NEW PROCEDURE       - THIS HAS TO RUN AGAINST ALL ORDERS, NOT JUST BATCH
	--MOVE BEGIN
	UPDATE dbo.tblOrders_Products 
	SET processType = 'Stock' 
	FROM dbo.tblOrders_Products AS op 
	INNER JOIN dbo.tblOrders o ON op.orderID = o.orderID
		AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS')
	WHERE (op.processType IS NULL OR op.processType <> 'Stock')
	AND EXISTS
		(SELECT TOP 1 1
		FROM dbo.tblProducts AS p 
		WHERE op.productid = p.productid 
		AND productType = 'Stock') --good
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	--// CUSTOM (1/3) --------------------------------------------
	INSERT INTO dbo.tblMigLog (migStamp,migTime, migStoredProc) SELECT 'A1', GETDATE(),'MIG_ProcessType_Patcher'

	UPDATE op
	SET processType = 'Custom'
	FROM dbo.tblOrders_Products AS op 
	INNER JOIN dbo.tblOrders o ON op.orderID = o.orderID AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS')
	WHERE (processType IS NULL OR processType = 'Stock')
	AND EXISTS 
		(SELECT TOP 1 1
		FROM dbo.tblProducts AS o 
		WHERE op.productID = o.productID
		AND productType = 'Custom')
	AND op.fastTrak_status <> 'Good to Go' --good
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	--// CUSTOM (2/3) --------------------------------------------	
	UPDATE op
	SET processType = 'Custom'
	FROM dbo.tblOrders_Products AS op 
	INNER JOIN 
	(
		SELECT p.ProductCode
		FROM tblProducts AS p 
		INNER JOIN tblSwitch_productCodes s ON s.productCode = SUBSTRING(p.productCode, 1, 2)
		WHERE productType = 'fasTrak'
		AND SUBSTRING(p.productCode, 1, 2) <> 'NB'
	) x 
		ON x.ProductCode = op.productCode
	INNER JOIN dbo.tblOrders o ON op.orderID = o.orderID
			AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS')
	LEFT JOIN tblOrdersProducts_productOptions OPPO ON op.Id = OPPO.ordersProductsID
			AND oppo.deleteX <> 'yes'
			AND (oppo.optionCaption = 'OPC' --(1/3:  we do not want OPC FT OPIDs to be set to "custom" productType.)
					 OR oppo.optioncaption = 'template back' --(2/3: we do not want business card OPIDs who have the following unique template back, set as "custom" productType for Gluon OPIDs.)
						AND oppo.textvalue = 'Templates/BusinessCards-Backs/BP00H1-003-100-BACK.QXP'
					 OR oppo.optionID = 563 --(3/3: "Upload Your Own Back"; we do not want the uploaded business card backs to be set to "custom" productType for Canvas OPIDs.)
					 OR oppo.optionCaption = 'CC State ID' --this deals with OPIDs that dont have the OPC OPPO
					 )
	LEFT JOIN dbo.tblOrdersProducts_productOptions  OPPO2 ON op.Id = OPPO2.ordersProductsID
			AND oppo2.deleteX <> 'yes'
			AND oppo2.optionid = 518
	WHERE 
	(OPPO.optionID IS NULL
		OR oppo2.optionID IS NOT NULL)
	AND (processType IS NULL 
		OR processType <> 'Custom')
	AND op.fastTrak_status <> 'Good to Go' --horror, good.
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	--// CUSTOM (2.5/3) --------------------------------------------	
	UPDATE op
	SET processType = 'Custom'
	FROM tblOrders_Products AS op 
	INNER JOIN tblOrdersProducts_ProductOptions oppo ON op.ID = oppo.ordersProductsID
	WHERE SUBSTRING(op.productCode, 3, 2) = 'PM'
	AND SUBSTRING(op.productCode, 1, 2) NOT IN ('NC')
	
	--// CUSTOM (3/3) --------------------------------------------	
	UPDATE op
	SET processType = 'Custom'
	FROM tblOrders_Products AS op 
	INNER JOIN tblOrdersProducts_ProductOptions oppo ON op.ID = oppo.ordersProductsID
	INNER JOIN tblOrders o ON op.orderID = o.orderID
			AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS')
	WHERE op.processType <> 'Custom'
	AND op.productCode LIKE 'BP%'
	AND oppo.optionID IN (573, 574) --good
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)


	--// FASTRAK --------------------------------------------
	--  if the product is productType = 'fasTrak', set processType = 'fasTrak'
	--	 because a 'Custom' product can actually go thru either processType ('Custom', 'fasTrak') as seen in the 2nd part of Custom which deals with pick and prints.
	INSERT INTO dbo.tblMigLog (migStamp,migTime, migStoredProc) SELECT 'B1', GETDATE(),'MIG_ProcessType_Patcher'


	--Update OPIDs to FT where they're not already FT and they have not been assigned to Custom yet, we will deal with exceptions after this.
	UPDATE dbo.tblOrders_Products
	SET processType = 'fasTrak'
	FROM tblOrders_products AS op
	INNER JOIN dbo.tblOrders o ON op.orderID = o.orderID
		AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS')
	WHERE ISNULL(processType, '') NOT IN ('fasTrak', 'custom')
	AND EXISTS 
		(SELECT TOP 1 1
		FROM dbo.tblProducts AS p 
		WHERE op.productid = p.productid 
		AND productType = 'fasTrak') --good
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	--2020 calendars were not coming in; added this override, jf. WE NEED TO RETHINK THIS SECTION. IT NEEDS TO WORK FOR NON-CAL PRODUCTS.
	UPDATE dbo.tblOrders_Products
	SET processType = 'fasTrak'
	FROM tblOrders_products AS op
	INNER JOIN dbo.tblOrders o ON op.orderID = o.orderID
		AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS')
	WHERE (processType = 'custom' OR processType = 'Stock') 
	AND EXISTS 
		(SELECT TOP 1 1
		FROM dbo.tblProducts AS p 
		WHERE op.productid = p.productid 
		AND productType <> 'Stock')
	AND (
		op.productCode LIKE 'CA__20%'
		OR 
		(op.productCode LIKE 'CA__00%' AND op.productCode NOT LIKE 'CAPM00%')
		OR
		(op.productCode LIKE 'FB__00%' AND op.productCode NOT LIKE 'FBPM00%')  --Shreck did some dirty here to fix Postcard Mailers
		OR
		(op.productCode LIKE 'BB__00%' AND op.productCode NOT LIKE 'BBPM00%')  --Shreck did some dirty here to fix Postcard Mailers
		)		
	AND EXISTS
		(SELECT TOP 1 1
		FROM tblOrdersProducts_productOptions oppx
		WHERE ((oppx.optionCaption = 'OPC' and oppx.deletex <> 'yes')
				OR 
				(oppx.optionCaption = 'CC State ID' and oppx.deletex <> 'yes')) --this deals with OPIDs that dont have the OPC OPPO)
		AND op.id = oppx.ordersproductsid) --horror, good.
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	--OVERRIDE: relates to Business Cards. Currently, BCs are custom but we are pushing them thru FT. (08/03/18 JF)
	UPDATE op
	SET processType = 'fasTrak'
	FROM tblOrders_products AS op
	INNER JOIN tblOrders o ON op.orderID = o.orderID
		AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS')
	WHERE processType = 'Custom'
	AND EXISTS 
		(SELECT TOP 1 1
		FROM tblProducts AS p 
		WHERE op.productid = p.productid 
		AND productType = 'fasTrak'
		AND productCode LIKE 'BP%')
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOrdersProducts_ProductOptions oppo
		WHERE op.ID = oppo.ordersProductsID
		AND oppo.deleteX <> 'yes'
		AND oppo.optionID IN (573, 574)) --good
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)


	
	DECLARE @cte TABLE (rownum int identity(1,1), OrderId Int)

	INSERT @cte 
	SELECT DISTINCT op.orderID 
	FROM tblOrders_Products op
	INNER JOIN tblOrders o ON op.orderID = o.orderID
	WHERE    op.deleteX <> 'yes'
		AND DATEDIFF(DD, o.created_on, GETDATE()) <= 365
		AND DATEDIFF(hh, op.modified_on, GETDATE()) <= 8

	--// 1. Update FasTrak orders.
	UPDATE o
	SET orderType = 'FasTrak'
	from dbo.tblOrders o
	INNER JOIN @cte c ON c.OrderId = o.orderID 
	WHERE orderType <> 'fasTrak'
	AND EXISTS
		(SELECT TOP 1 1
		FROM dbo.tblOrders_Products as op
		WHERE o.orderid = op.orderid 
		and deleteX <> 'yes'
		AND processType = 'fasTrak')
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM dbo.tblOrders_Products as op
		WHERE o.orderid = op.orderid 
		and deleteX <> 'yes'
		AND processType = 'Custom')
	AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS') --good

	--// 2. Update Custom orders, as they supercede all before it.
	UPDATE o
	SET orderType = 'Custom'
	from dbo.tblOrders o
	INNER JOIN @cte c ON c.OrderId = o.orderID 
	WHERE orderType <> 'Custom'
	AND EXISTS
		(SELECT TOP 1 1
		FROM dbo.tblOrders_Products as op
		WHERE o.orderid = op.orderid 
		and deleteX <> 'yes'
		AND processType = 'Custom')
	AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS') --good

	--// 3. revert to Stock if fasTrak or Custom opid was removed from that order that was previously marked as either.
	UPDATE o
	SET orderType = 'Stock'
	from dbo.tblOrders AS o 
	INNER JOIN @cte c ON c.OrderId = o.orderID 
	WHERE orderType <> 'Stock'
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM dbo.tblOrders_Products as op 
		WHERE o.orderid = op.orderid 
			AND deleteX <> 'yes'
			AND processType in ('Custom','fasTrak'))
	AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS') --good

	INSERT INTO dbo.tblMigLog (migStamp,migTime, migStoredProc) SELECT 'END', GETDATE(),'MIG_ProcessType_Patcher'

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH