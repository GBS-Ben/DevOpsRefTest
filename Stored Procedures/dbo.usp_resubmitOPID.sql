

CREATE PROC [dbo].[usp_resubmitOPID]
@OPID INT, 
@resubmitQTY INT = 0,
@resubmitChoice INT = 1,
@nolog bit = 0
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     1/1/2014
Purpose     This is the primary resubmission sproc used on orderView.asp, as well as other locations. 

EXEC usp_resubmitOPID 556083627,0,1,1
EXEC usp_resubmitOPID 556082528,0,1,1

,0,1,1/nEXEC usp_resubmitOPID 
-------------------------------------------------------------------------------
Modification History

01/01/14		Created, jf
05/11/18		updated with new reprint choices, jf
05/15/18		updated with new resub concepts, jf
07/13/18		update productCode prefix stuff.
07/16/18		note: pUnit table is not updated by this code because the BC switch flow will dump any rows in that table upon tblOrders_products.fastTrak_resubmit = 1.
07/17/18		Removed "tblSwitch_Resubmit" update, jf.
10/03/18		Fixed fastTrak_shippingLabelOption section to point to the correct values, they were all being set to 1 despite what the @resubmitChoice was, jf.
10/24/18		Added notes and general cleanup, jf.
05/13/19		Resub choices were stuck inside the NB loop; pulled them out, jf.
05/28/19		Added cleaner step, jf.
10/11/19		Added stream=0 in update statement, jf.
10/30/20		BJS, added @nolog ("1" is a bypass)
12/30/20		JF, added section at the bottom of the proc that takes care of the deletion of OPID records in tblOPPO_fileExists
-------------------------------------------------------------------------------
*/
--Get productCode prefix details for product-specific resubmit functions
DECLARE @productCodePrefix NVARCHAR(2) = 'XX'
SET @productCodePrefix = (SELECT SUBSTRING(productCode, 1, 2)
											FROM tblOrders_Products 
											WHERE ID = @OPID)

--if resubmitted qty is 0, update it to the originally ordered quantity
IF @resubmitQTY = 0
BEGIN
	SET @resubmitQTY = (SELECT productQuantity
										FROM tblOrders_Products
										WHERE @OPID = [ID]
										AND productQuantity IS NOT NULL)
END

--update fasTrak fields for resubmission
UPDATE tblOrders_Products
SET  fastTrak_resubmit = 1, 
	 switch_create = 0, 
	 stream = 0, --this is used by the signs flow
	 switch_createDate = NULL, 
	 fastTrak_newQTY = @resubmitQTY,
	 fastTrak_status = 'Good to Go', 
	 fastTrak_status_lastModified = GETDATE(),
	 fastTrak_imageFile_exported = 0,
	 fastTrak_imageFile_exportedOn = NULL
WHERE [ID] = @OPID

--Additional steps for Name Badges
IF @productCodePrefix = 'NB'
BEGIN
	--update additional badge-specific fasTrak fields for resubmission if OPID is a badge
	UPDATE tblOrders_Products
	SET fastTrak_reimage = 1,
			fastTrak_imposed = 0,
			fastTrak_preventLabel = 0, 
			fastTrak_preventTicket = 0, 
			fastTrak_preventImposition = 1
	WHERE [ID] = @OPID
END

--resubmitChoice --------------------------------------------------------------------------------------------------------
--first clear previous resubmitChoice values
UPDATE tblOrders_Products
SET fastTrak_shippingLabelOption1 = 0,
	   fastTrak_shippingLabelOption2 = 0,
	   fastTrak_shippingLabelOption3 = 0
WHERE [ID] = @OPID

--update resubmitChoice values
UPDATE tblOrders_Products
SET fastTrak_shippingLabelOption1 = 1
WHERE [ID] = @OPID
AND @resubmitChoice = 1

UPDATE tblOrders_Products
SET fastTrak_shippingLabelOption2 = 1
WHERE [ID] = @OPID
AND @resubmitChoice = 2

UPDATE tblOrders_Products
SET fastTrak_shippingLabelOption3 = 1
WHERE [ID] = @OPID
AND @resubmitChoice = 3
----------------------------------------------------------------------------------------------------------------------------------
--BJS 10302020 added @nolog parameter to by pass logging which triggers RESUB on the production tickets
IF @nolog = 0
BEGIN
	--log the action in the new table
	INSERT INTO tblSwitch_resubOption (OPID, resubmitQTY, resubmitChoice, resubmitDate)
	SELECT  @OPID, @resubmitQTY, @resubmitChoice, GETDATE()

	--log the action in the old tables (until phased out)
	INSERT INTO tblFT_QTYResubmit (ordersProductsID, QTY, submitDate)
	SELECT @OPID, @resubmitQTY, GETDATE()
END 

--Cleaner
UPDATE tblOrders_Products
SET fastTrak_resubmit = 1
WHERE fastTrak_status IN ('Resubmitted for Print', 'Good to Go')
AND fastTrak_resubmit = 0

----------------------------------------------------------------------------------------------------------------------------------
--Upon resubmission, kill any row in tblOPPO_fileExists that corresponds to the OPID being resubbed.
--Currently only doing this for BP, NC, QC, QM, which are the product lines that are operated against on usp_OPPO_validateFile

DELETE FROM tblOPPO_fileExists
WHERE OPID = @OPID
AND EXISTS
	(SELECT TOP 1 1
	FROM tblOrders_Products op
	WHERE op.deleteX <> 'yes'
	AND (SUBSTRING(op.productCode, 1, 2) IN ('BP', 'NC','SN')
			 OR SUBSTRING(op.productCode, 3, 2) IN ('QC', 'QM')
			 OR (op.productCode like 'NB__S%' and op.productCode NOT LIKE 'NB___U%')
			 )
	AND op.ID = tblOPPO_fileExists.OPID)

DELETE p
FROM [dbo].[tblPrintFileMoverLog] p
WHERE  OPID = @OPID


/*
What type of resubmission is this?

1.	Production Error
2.	Reprint – Ship Alone
3.	Reprint – Ship Whole Order

THREE CHOICES FOR RESUB
1.	IS THIS A PRODUCTION ERROR? i resub it, that opid stands alone, sorts to front. This also affects how tickets generate their shipsWith section (e.g., red label for @resubmitChoice = 1)
2.	IS THIS A REPRINT from the client (not whole order)?
	A.	if it’s only a single product, then it ships by itself
	B.	if it’s a couple products (e.g. out of 5, they chose to resub 2)
	not common however, need to update shipsWith to recognize other resubbed opid(s)
	worse case scenario, they both say “SHIP”, and we waste a little money
3.	IS THIS A REPRINT (whole order?)
1.	when it is the whole order, in the future, can we resub all opids in order.
*/