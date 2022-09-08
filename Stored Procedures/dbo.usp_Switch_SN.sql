CREATE PROCEDURE [dbo].[usp_Switch_SN] 

AS
/*
----------------------------------------------------------------------------------------------------------------------------
Author      Bobby
Created     08/3/14
Purpose     Presents SIGN data to Switch for reference
----------------------------------------------------------------------------------------------------------------------------
Modification History

05/22/18		BS, New
07/29/19		AC, Line 33, only submit jobs older than 10 mintues to allow migration fixes to be applied first
11/12/19		JF, added the "SNFA" code to the initial query. This should help with Furnished Art. When a CSR "Good to Go's" the sign which is processType = 'custom', the G2G changes the processType to 'fasTrak'. This is essentially, a QA GATE prior to building sign.
11/14/19		JF, added readyForSwitch check.
1/10/20			BS, This flow is not used.  DO NOT USE IT
01/13/20		JF, Got rid of CRUD at bottom, and now it's back.
02/05/20		JF, added Credit Due to main query.
04/21/21		CKB, modified file check #5
-------------------------------------------------------------------------------
*/
SET NOCOUNT ON;


 RETURN;   ---TURN BACK--NOTHING TO SEE HERE--THIS PROC IS NOT YOUR FRIEND


BEGIN TRY

	INSERT INTO tblSwitch_SN_OPC (ordersProductsID, orderID, orderNo)
	SELECT DISTINCT op.[ID], o.orderID, o.orderNo
	FROM tblOrders_Products op
	INNER JOIN tblOrders o
		ON op.orderID = o.orderID
	WHERE op.deleteX <> 'yes'
	AND LEFT(op.productCode, 2) = 'SN'
	AND o.orderStatus NOT IN ('failed', 'cancelled', 'delivered')
	AND o.orderStatus NOT LIKE '%Transit%'
	AND o.displayPaymentStatus IN ('Good', 'Credit Due')
	AND (op.productCode NOT LIKE 'SNFA%' AND op.processType <> 'fasTrak'
		OR op.productCode LIKE 'SNFA%' AND op.processType = 'fasTrak') 
	AND DATEDIFF(MINUTE, o.orderDate, GETDATE()) > 10
	AND LEN(o.orderNo) = 9
	AND op.ID NOT IN
		(SELECT DISTINCT ordersProductsID
		FROM tblSwitch_SN_OPC
		WHERE ordersProductsID IS NOT NULL)
	AND op.ID NOT IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionID = 518)
	--Image Check ----------------------------------
	--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
	AND EXISTS			--must have a file	
		(SELECT TOP 1 1
		FROM tblOPPO_fileExists e
		WHERE e.OPID = op.id)

	AND NOT EXISTS		-- none of the files can be missing/broken		
		(SELECT TOP 1 1
		FROM tblOPPO_fileExists e
		WHERE e.readyForSwitch = 0
		AND e.OPID = op.id)










	--// update any OPIDs whose OPPO data has changed since last modified_on date in tblSwitch_SN_OPC
	--	   this is controlled by customDataSynced. This BIT field defaults to "1", but here, is set to "0" if the 
	--	   corresponding OPPO data has been modified recently and those modifications are not reflected yet here.
	--		the changes will now reflect, and the OPID will be re-presented to Switch.
	--BJS 06292018 Added update the Modified_On date so the OPID doesnt keep getting processed.
	UPDATE tblSwitch_SN_OPC
	SET customDataSynced = 0,
	presentedToSwitch = 0,
	presentedToSwitch_on = NULL,
	modified_on = (SELECT MAX (modified_on)_ FROM  tblOrdersProducts_ProductOptions po WHERE a.ordersProductsID = po.ordersProductsID)
	FROM tblSwitch_SN_OPC a
	INNER JOIN tblOrdersProducts_ProductOptions b
		ON a.ordersProductsID = b.ordersProductsID
	WHERE 	a.modified_on < b.modified_on

	--// retrieve FRONT data for all newly inserted (and recently updated) OPIDs
	--(1/2) CLASSIC
	UPDATE tblSwitch_SN_OPC
	SET fileName_front = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
	FROM tblSwitch_SN_OPC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	AND b.deleteX <> 'yes'
	AND b.optionCaption = 'File Name 2'
	AND (a.presentedToSwitch = 0
			OR a.customDataSynced = 0)

	--(2/2) CANVAS
	UPDATE tblSwitch_SN_OPC
	SET fileName_front = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
	FROM tblSwitch_SN_OPC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	AND b.deleteX <> 'yes'
	AND b.optionCaption = 'Intranet PDF'
	AND a.fileName_front is NULL
	AND (a.presentedToSwitch = 0
			OR a.customDataSynced = 0)

	--// retrieve BACK data (where applicable) for all newly inserted (and recently updated) OPIDs
	--(1/2) CLASSIC
	UPDATE tblSwitch_SN_OPC
	SET fileName_back = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
	FROM tblSwitch_SN_OPC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	AND b.deleteX <> 'yes'
	AND b.optionCaption = 'Product Back'
	AND (a.presentedToSwitch = 0
			OR a.customDataSynced = 0)
			
	--(2/2) CANVAS
	UPDATE tblSwitch_SN_OPC
	SET fileName_back = REPLACE((RIGHT(b.textValue, CHARINDEX('/', REVERSE(b.textValue)))), '/', '')
	FROM tblSwitch_SN_OPC a
	INNER JOIN tblOrdersProducts_productOptions b
		ON a.ordersProductsID = b.ordersProductsID
	AND b.deleteX <> 'yes'
	AND b.optionCaption = 'Back Intranet PDF'
	AND (a.presentedToSwitch = 0
			OR a.customDataSynced = 0)

	UPDATE tblSwitch_SN_OPC
	SET fileName_back = ''
	WHERE fileName_back LIKE '%BLANK%'
	AND (presentedToSwitch = 0
			OR customDataSynced = 0)

	--Step to log current batch of OPID/Punits
	declare @CurrentDate datetime = getdate() --Get current date for batch
	insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
	select 
	flowName = 'SN'
	,a.PKID
	,a.ordersProductsID
	,batchTimestamp = @CurrentDate
	,jsonData = 
		   (select *
		   from (select PKID = ROW_NUMBER() over (order by ordersProductsID), * from tblSwitch_SN_OPC where presentedToSwitch = 0 AND fileName_front IS NOT NULL) b
		   where a.PKID = b.PKID
		   for json path)
	from (select PKID = ROW_NUMBER() over (order by ordersProductsID), * from tblSwitch_SN_OPC where presentedToSwitch = 0 AND fileName_front IS NOT NULL) a

	---- Update OPID status fields indicating successful submission to switch
	--UPDATE op
	--SET switch_create = 1,
	--	fastTrak_status = 'In Production',
	--	fastTrak_status_lastModified = GETDATE(),
	--	fastTrak_resubmit = 0	
	--FROM tblOrders_Products op
	--INNER JOIN tblSwitch_SN_OPC q ON op.ID = q.ordersProductsID
	--WHERE q.presentedToSwitch = 0
	--	and q.fileName_front is not null

	--// retrieve new records for Switch presentation
	SELECT orderNo,ordersProductsID,  fileName_front, fileName_back 
	FROM tblSwitch_SN_OPC
	WHERE presentedToSwitch = 0
		AND fileName_front IS NOT NULL

		
	--// update all records to prevent further presentation of data
	UPDATE tblSwitch_SN_OPC
	SET presentedToSwitch = 1, 
	presentedToSwitch_on = GETDATE()
	WHERE presentedToSwitch = 0
		AND fileName_front IS NOT NULL

	-- update  all records whose custom data has just been synced
	UPDATE tblSwitch_SN_OPC
	SET customDataSynced = 1
	WHERE customDataSynced = 0
		AND fileName_front IS NOT NULL

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH