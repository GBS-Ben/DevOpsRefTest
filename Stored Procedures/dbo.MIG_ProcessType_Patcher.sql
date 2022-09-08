/*
12/17/20	CKB, added try/catch
12/21/20	CKB, added temp table logic to avoid multiple update/where statements on processtype
02/11/21	CKB, added new oppos for BP paper stock
02/19/21	BS, added custom section 4 and 5
02/22/21	CKB, modified custom section 5 to only include envelopes with CU or return address
02/24/21	CKB, removed inserts from fasttrak code - their custom status was being overwritten
04/14/21	JF, made it so that FB shapes do not get set to FT.
08/17/21	CKB, FB QS - custom
08/18/21	CKB, fix FB QA to by just CYO with 243
09/23/21	JF, BOCKEY 2021.
09/27/21	JF, MISSING "NOT" in the IN STATEMENT in the "Horror, Good" Query.
09/29/21	CKB, put insert exclusion back in to Fastrak so they preserve their custom status
09/30/21	CKB, excluded both envelopes and inserts from FT and removed stateid condition since WDIFY project send it always
10/21/21	CKB, added op.productCode not like 'FBQS%-243%'	to FT logic to keep them custom
*/

CREATE PROCEDURE [dbo].[MIG_ProcessType_Patcher]
AS


BEGIN TRY

	INSERT INTO dbo.tblMigLog (migStamp,migTime, migStoredProc) SELECT 'BEG', GETDATE(),'MIG_ProcessType_Patcher'

	IF OBJECT_ID('tempdb..#ProcessType') IS NOT NULL
		DROP TABLE #ProcessType

	SELECT o.orderid,op.id,op.productID,op.processType,op.fastTrak_status,op.productcode
	INTO #ProcessType
	FROM dbo.tblOrders_Products AS op 
	INNER JOIN dbo.tblOrders o ON op.orderID = o.orderID
		AND o.orderStatus NOT IN ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS')

	CREATE NONCLUSTERED INDEX [NCI_ProcessType_productcode]
	ON [dbo].[#ProcessType] ([processType],[productcode])
	INCLUDE ([id])

	CREATE NONCLUSTERED INDEX [NCI_ID]
	ON [dbo].[#ProcessType] ([id])
	INCLUDE ([processType])

	--MOVE THESE TO A NEW PROCEDURE       - THIS HAS TO RUN AGAINST ALL ORDERS, NOT JUST BATCH
	--MOVE BEGIN
	UPDATE #ProcessType 
	SET processType = 'Stock' 
	FROM #ProcessType AS op 
	WHERE (op.processType IS NULL OR op.processType <> 'Stock')
	AND EXISTS
		(SELECT TOP 1 1
		FROM dbo.tblProducts AS p 
		WHERE op.productid = p.productid 
		AND productType = 'Stock') --good
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	--// CUSTOM (1/5) --------------------------------------------
	INSERT INTO dbo.tblMigLog (migStamp,migTime, migStoredProc) SELECT 'A1', GETDATE(),'MIG_ProcessType_Patcher'

	UPDATE #ProcessType
	SET processType = 'Custom'
	FROM #ProcessType AS op 
	WHERE (processType IS NULL OR processType = 'Stock')
	AND EXISTS 
		(SELECT TOP 1 1
		FROM dbo.tblProducts AS o 
		WHERE op.productID = o.productID
		AND productType = 'Custom')
	AND op.fastTrak_status <> 'Good to Go' --good
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	--// CUSTOM (2/5) --------------------------------------------	
	UPDATE op
	SET processType = 'Custom'
	FROM #ProcessType AS op 
	INNER JOIN 
	(
		SELECT p.ProductCode
		FROM tblProducts AS p 
		INNER JOIN tblSwitch_productCodes s ON s.productCode = SUBSTRING(p.productCode, 1, 2)
		WHERE productType = 'fasTrak'
		AND SUBSTRING(p.productCode, 1, 2) <> 'NB'
	) x 
		ON x.ProductCode = op.productCode
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

	--// CUSTOM (2.5/5) --------------------------------------------	
	UPDATE op
	SET processType = 'Custom'
	FROM #ProcessType AS op 
	INNER JOIN tblOrdersProducts_ProductOptions oppo ON op.ID = oppo.ordersProductsID
	WHERE SUBSTRING(op.productCode, 3, 2) = 'PM'
		AND SUBSTRING(op.productCode, 1, 2) NOT IN ('NC')
		AND op.processType <> 'Custom'
	
	--// CUSTOM (2.75/5) --------------------------------------------	
	UPDATE op
	SET processType = 'Custom'
	FROM #ProcessType AS op 
	WHERE op.productCode like 'FBQS%-243%'		-- per Brian - JIRA BR-77
		AND op.processType <> 'Custom'

	--// CUSTOM (3/5) --------------------------------------------	
	UPDATE op
	SET processType = 'Custom'
	FROM #ProcessType AS op 
	INNER JOIN tblOrdersProducts_ProductOptions oppo ON op.ID = oppo.ordersProductsID
	WHERE op.processType <> 'Custom'
	AND op.productCode LIKE 'BP%'
	AND (oppo.optionID IN (573, 574) --good
	 OR (optionCaption='Paper Stock' and (textValue like '%32%pt%' or textValue like '%52%pt%')))	-- changed textvalues
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	--// CUSTOM (4/5) --------------------------------------------	
	UPDATE p
	SET processType = 'Custom'
	FROM #ProcessType p
	WHERE p.processType <> 'Custom'
		AND EXISTS (SELECT TOP 1 1 FROM  tblOrdersProducts_ProductOptions oppo WHERE  p.id = oppo.ordersProductsID 
					AND optioncaption = 'Default Layout' 
					AND TextValue LIKE '%_J'  --upload your own art layout.  These need to be good to go to enter FastTrak
					AND Deletex <> 'yes'
					)
		AND p.fastTrak_status = 'In House'

	--// CUSTOM (5/5) --------------------------------------------	
	update op
	set processtype = 'Custom'  
	FROM tblOrders o 
	INNER JOIN #ProcessType op ON op.OrderId=o.OrderId
	WHERE orderStatus NOT IN ('cancelled','failed','delivered','in transit','In Transit USPS')
		AND (LEFT(op.Productcode,4) IN  ('CAIN', 'BBIN', 'FBIN',  'FAIN',  'EVKW')
			OR op.productCode LIKE '__PM%' -- Postcards
			OR op.productCode LIKE '__FA%' --Furnished Art
			OR op.ProductCode like 'PL%'
			OR (LEFT(op.Productcode,4) IN  ('EVCA', 'EVBB', 'EVFB', 'EVFA', 'NCEV')
				AND (op.productCode LIKE '%CU%' OR EXISTS (SELECT top 1 1 FROM tblOrdersProducts_ProductOptions oppo where oppo.ordersProductsId = op.ID and oppo.optioncaption = 'Return Address Placement'))
				)
			)
		AND processType <> 'Custom'
		AND op.fastTrak_status = 'In House'

	--// FASTRAK --------------------------------------------
	--  if the product is productType = 'fasTrak', set processType = 'fasTrak'
	--	 because a 'Custom' product can actually go thru either processType ('Custom', 'fasTrak') as seen in the 2nd part of Custom which deals with pick and prints.
	INSERT INTO dbo.tblMigLog (migStamp,migTime, migStoredProc) SELECT 'B1', GETDATE(),'MIG_ProcessType_Patcher'


	--Update OPIDs to FT where they're not already FT and they have not been assigned to Custom yet, we will deal with exceptions after this.
	UPDATE #ProcessType
	SET processType = 'fasTrak'
	FROM #ProcessType AS op
	WHERE ISNULL(processType, '') NOT IN ('fasTrak', 'custom')
	AND EXISTS 
		(SELECT TOP 1 1
		FROM dbo.tblProducts AS p 
		WHERE op.productid = p.productid 
		AND productType = 'fasTrak') --good

	--2020 calendars were not coming in; added this override, jf. WE NEED TO RETHINK THIS SECTION. IT NEEDS TO WORK FOR NON-CAL PRODUCTS.
	UPDATE #ProcessType
	SET processType = 'fasTrak'
	FROM #ProcessType AS op
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
		(op.productCode LIKE 'FB__00%' AND op.productCode NOT LIKE 'FBPM00%' AND op.productCode NOT LIKE 'FBHM00%' AND op.productCode NOT LIKE 'FBFB00%' AND op.productCode NOT like 'FBQS%-243%'	)  --Shreck did some dirty here to fix Postcard Mailers ; Fife added Helmets and FB Shapes --CKB, added op.productCode NOT like 'FBQS%-243%'	
		OR
		(op.productCode LIKE 'BB__00%' AND op.productCode NOT LIKE 'BBPM00%')  --Shreck did some dirty here to fix Postcard Mailers
		OR
		(op.productCode LIKE 'HY__00%' AND op.productCode NOT LIKE 'HYPM00%') -- JF, HOCKEY 2021.
		OR 
		(op.productCode LIKE 'BK__00%' AND op.productCode NOT LIKE 'BKPM00%') -- JF, BASKETBALL 2021. This is stupid.
		)	
	AND (LEFT(op.Productcode,4) NOT IN  ('CAEV', 'BBEV', 'FBEV', 'FAEV', 'NCEV', 'EVKW','CAIN', 'BBIN', 'FBIN',  'FAIN'))  -- CKB removed inserts - they are marked custom in 5/5 above ||JF added "NOT". It was missing. 9/27/21.-- CKB,excluding inserts and envelopes
	AND EXISTS
		(SELECT TOP 1 1
		FROM tblOrdersProducts_productOptions oppx
		WHERE ((oppx.optionCaption = 'OPC' and oppx.deletex <> 'yes'))  --- ckb, removed state id becuase all have state id now
		AND op.id = oppx.ordersproductsid) --horror, good.
	AND NOT EXISTS (SELECT TOP 1 1 FROM  tblOrdersProducts_ProductOptions oppo WHERE  op.id = oppo.ordersProductsID 
				AND optioncaption = 'Default Layout' 
				AND TextValue LIKE '%_J'  --upload your own art layout.  These need to be good to go to enter FastTrak
				AND Deletex <> 'yes'
				)

	--OVERRIDE: relates to Business Cards. Currently, BCs are custom but we are pushing them thru FT. (08/03/18 JF)
	UPDATE op
	SET processType = 'fasTrak'
	FROM #ProcessType AS op
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
		AND (oppo.optionID IN (573, 574) --good
		 OR (optionCaption='Paper Stock' and (textValue like '%32%pt%' or textValue like '%52%pt%'))))	-- changed textvalues
	--and exists (select top 1 1 from gbsstage.dbo.tblNOP_order_RIP r where r.migID = op.orderID and r.[RowVersion] = @RowVersion)

	UPDATE op with (rowlock)
	SET processType = tmp.processType
	--select op.processType,tmp.processType
	FROM tblOrders_Products op
	INNER JOIN #ProcessType tmp on op.ID = tmp.ID
	WHERE ISNULL(op.processType,'') <> ISNULL(tmp.processType,'')
	
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