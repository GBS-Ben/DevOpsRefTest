CREATE PROC [dbo].[Migration_Patcher]
@Status VARCHAR(255) OUTPUT,
@ErrMsg NVARCHAR(4000) OUTPUT
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     01/24/19
Purpose		Patches NOP OPPO after MIGNOP has run.
-------------------------------------------------------------------------------
Modification History

01/24/19	Created, jf.
01/28/19	BS, deleting options that should not be deleted.
01/29/19	BS, Fix 1 disabled.  Added optionPrice = 0 and Fixed Missed () around or.
02/02/19	BS, removed 534 deletes
04/25/19	JF, updated Fix 3,4,6 and 7; added: AND "optionPrice = 0" to top portion.
08/05/20	JF, added Fix #11, grommets.
02/08/21	CKB, added isnumeric to grommet count
02/10/21	CKB, turning off grommet the frog 509/510 do not have price and are depricated
05/20/21	CKB, adapted from MIG_OPPO_Patcher for new migration process
-------------------------------------------------------------------------------
*/

--This is a script to add to MIGNOP that fixes much of the duplicatation from the JSON parse, 
--as well as preps OPPOs for proper display on Intranet, JobTicket, etc.


--Fix 1 ------------------------------------------
--This makes "Design Fee" visible on the JobTicket.
-- 0 seconds
BEGIN TRY
	UPDATE oppx
	SET oppx. optionGroupCaption = 'Custom Info'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.optionID = 252
	AND oppx.optionCaption = 'Design Fee'
	AND oppx.optionGroupCaption <> 'Custom Info'

	--Fix 2 ------------------------------------------
	-- Fix double colon issue on Info Line data.
	-- 0 seconds
	UPDATE oppx 
	SET oppx.optionCaption = REPLACE(oppx.optionCaption, ':', '')
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.optionCaption LIKE 'Info Line%:%'

	--Fix 3 ------------------------------------------
	--This removes "Square: 1" from OPPO if "Corners: Square Corners" exists.
	-- 0 seconds

	UPDATE oppx
	SET deleteX = 'yes'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.optionID = 570
	AND oppx.deletex <> 'yes'
	AND oppx.optionPrice = 0
	AND EXISTS
		(SELECT TOP 1 ordersProductsID
		FROM #tblOrdersProducts_productOptions_Stage oppz
		WHERE oppz.optionCaption = 'Corners' 
		AND oppz.textValue = 'Square Corners'
		AND oppz.deleteX <> 'yes'
		AND oppz.optionPrice = 0
		AND oppz.ordersProductsID = oppx.ordersProductsID)

	--Fix 4 ------------------------------------------
	--This removes "Standard 16 pt: 1" from OPPO if "Paper Stock..." exists.
	-- 0 seconds

	UPDATE oppx
	SET deleteX = 'yes'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.optionID = 572
	AND oppx.optionPrice = 0
	AND oppx.deletex <> 'yes'
	AND EXISTS
		(SELECT TOP 1 ordersProductsID
		FROM #tblOrdersProducts_productOptions_Stage oppz
		WHERE oppz.optionCaption = 'Paper Stock' 
		AND oppz.textValue = 'Standard 16 pt Card'
		AND oppz.deleteX <> 'yes'
		AND oppz.optionPrice = 0
		AND oppz.ordersProductsID = oppx.ordersProductsID)

	--Fix 5 ------------------------------------------
	--This removes "Finish Options..." from OPPO if "Front Coating..." or "Back Coating..." exists in optionGroupCaption.
	--0 seconds

	UPDATE oppx
	SET deleteX = 'yes'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.optionCaption = 'Finish Options'
	AND oppx.deletex <> 'yes'
	AND oppx.optionPrice = 0
	AND EXISTS
		(SELECT TOP 1 ordersProductsID
		FROM #tblOrdersProducts_productOptions_Stage oppz
		WHERE oppz.deleteX <> 'yes'
		AND oppz.optionGroupCaption IN ('Front Coating', 'Back Coating')
		AND oppz.ordersProductsID = oppx.ordersProductsID)

	--Fix 6 ------------------------------------------
	--This removes "Add 20 Pages" from OPPO if the version with a price exists.
	--0 seconds

	UPDATE oppx
	SET oppx.deleteX = 'yes'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.optionID = 480
	AND oppx.optionPrice = 0
	AND oppx.deletex <> 'yes'
	AND EXISTS
		(SELECT TOP 1 ordersProductsID
		FROM #tblOrdersProducts_productOptions_Stage oppz
		WHERE oppz.deleteX <> 'yes'
		AND oppz.optionCaption = 'Add 20 Pages' 
		AND oppz.optionID <> 480
		AND oppz.optionPrice = 0
		AND oppz.ordersProductsID = oppx.ordersProductsID)

	--Fix 7 ------------------------------------------
	--This removes "Add Magnetic Back" from OPPO if the version with a price exists.
	--0 seconds

	UPDATE oppx
	SET deleteX = 'yes'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.optionID = 481
	AND oppx.optionPrice = 0
	AND oppx.deletex <> 'yes'
	AND EXISTS
		(SELECT TOP 1 ordersProductsID
		FROM #tblOrdersProducts_productOptions_Stage oppz
		WHERE oppz.optionCaption = 'Add Magnetic Back' 
		AND oppz.deleteX <> 'yes'
		AND oppz.optionID <> 481
		AND oppz.optionPrice = 0
		AND oppz.ordersProductsID = oppx.ordersProductsID)

	UPDATE oppx
	SET deleteX = 'yes'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.optionID IN (425, 515)
	AND oppx.deleteX <> 'yes'

	--Fix 8 ------------------------------------------
	--This removes "File Name 1" and "File Name 2" options that have image paths that are already showing elsewhere in the OPPO fields. This removes redundant "Web PDF" on OPIDs that have "Intranet PDF".
	--0 seconds

	UPDATE oppx
	SET deleteX = 'yes'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.deleteX <> 'yes'
	AND oppx.optionID IN (320, 336, 537)
	AND EXISTS
		(SELECT TOP 1 ordersProductsID
		FROM #tblOrdersProducts_productOptions_Stage oppz
		WHERE oppz.deleteX <> 'yes'
		AND oppz.optionID IN (537, 539)
		AND oppz.ordersProductsID = oppx.ordersProductsID)

	--Fix 9 ------------------------------------------
	--This gets Apparel options to show on the Job Ticket.
	--0 seconds

	UPDATE oppx
	SET optionGroupCaption = 'Custom Info' --select *
	FROM #tblOrdersProducts_productOptions_Stage oppx
	INNER JOIN #tblOrders_Products_Stage op ON oppx.ordersProductsID = op.ID
	WHERE oppx.optionCaption IN ('Size', 'Company Name')
	AND oppx.optionGroupCaption = 'Description'
	AND SUBSTRING(op.productCode, 1, 2) = 'AP'
	AND oppx.deleteX <> 'yes'

	--Fix 10 ------------------------------------------
	--This removes redundant "Back Web PDF" on OPIDs that have "Back Intranet PDF".
	--0 seconds

	UPDATE oppx
	SET deleteX = 'yes'
	FROM #tblOrdersProducts_productOptions_Stage oppx
	WHERE oppx.deleteX <> 'yes'
	AND oppx.optionID = 544
	AND EXISTS
		(SELECT TOP 1 ordersProductsID
		FROM #tblOrdersProducts_productOptions_Stage oppz
		WHERE oppz.deleteX <> 'yes'
		AND oppz.optionID IN (544, 546)
		AND oppz.ordersProductsID = oppx.ordersProductsID)

		SET @Status = 'Success'

	END TRY
	BEGIN CATCH
		
		SELECT @Status = 'Fail', @ErrMsg = 'MigrationPatcher - '  + ERROR_MESSAGE();
		RAISERROR (@ErrMsg,11,1);

	END CATCH