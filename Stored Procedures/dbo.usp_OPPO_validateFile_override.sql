CREATE PROCEDURE [dbo].[usp_OPPO_validateFile_override]
AS
/*-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     08/06/18
Purpose    Used to manually override a product line's fileExist check
				  when introducing a product line to the fileExist system.
				  This overrides the file check for all previously existing
				  opids that were delivered, or in transit. otherwise, the check
				  process has to run a function against hundreds of thousands
				  of opids.

				  This is used because the flows are all moving to a standardized
				  front query that only pulls out: 
							tblOrders.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
				 ...and since those flows bounce against the FileExist check system,
				 this system needs to check files for anything not listed above, meaning
				 statuses like "delivered" would set precedent over flow logic which
				 is not wanted.

				 [usp_OPPO_validateFile] The insert there must match too.
-------------------------------------------------------------------------------
Modification History

--08/06/18	    Created, jf.
--08/07/18	    Added PDF extension replacement on each statement, jf.
--08/10/18	    Trimmed entire sproc, added third statement, jf.
--09/28/18		Added ignoreCheck functionality, jf.
--10/16/18		Added orderStatus check, jf.
--10/16/18		Brought INSERT into sproc; it used to sit in MIG_MISC, jf.
-------------------------------------------------------------------------------
*/
INSERT INTO tblOPPO_fileExists (PKID, OPID, textValue, extension, overrideCheck, fileExists, fileChecked, fileCheckedOn)
SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3)), 1, 1, 1, GETDATE()
FROM tblOrdersProducts_productOptions oppo
INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
INNER JOIN tblOrders o ON op.orderID = o.orderID
LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
WHERE x.PKID IS NULL
AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
AND oppo.deleteX <> 'yes'
AND oppo.textValue NOT LIKE '%UserUploads%'
AND oppo.textValue NOT LIKE '%//canvas%'
AND oppo.textValue NOT LIKE '//houseofmagnets.com%'
AND oppo.textValue NOT LIKE 'https://rembrandt.houseofmagnets%'
AND oppo.textValue NOT LIKE '//www.houseofmagnets.com/images/business-card-backs%'
AND oppo.textValue NOT LIKE '/webstores/BusinessCards/StaticBacks/%'
AND op.processType = 'fasTrak'
AND o.orderStatus IN ('Delivered', 'In Transit', 'In Transit USPS')
AND (
		--BC
		SUBSTRING(op.productCode, 1, 2) = 'BP' 
		 OR
		--NC
		SUBSTRING(op.productCode, 1, 2) = 'NC'
				AND SUBSTRING(op.productCode, 3, 2) <> 'EV'
		--QC
		OR SUBSTRING(op.productCode, 3, 2) = 'QC'
				AND SUBSTRING(op.productCode, 1, 2) IN
							(SELECT productCode
							FROM tblSwitch_productCodes))

-- Should yield no updates:
/*
UPDATE x
SET x.overrideCheck = 1,
	   x.fileExists = 1,
	   x.fileChecked = 1,
	   x.fileCheckedOn = GETDATE() 
--SELECT oppo.PKID, oppo.ordersProductsID, oppo.textValue, UPPER(RIGHT(oppo.textValue, 3))
FROM tblOrdersProducts_productOptions oppo
INNER JOIN tblOrders_Products op ON oppo.ordersProductsID = op.ID
INNER JOIN tblOrders o ON op.orderID = o.orderID
LEFT JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
WHERE x.PKID IS NULL
AND RIGHT(oppo.textValue, 3) IN ('PDF', 'JPG')
AND oppo.deleteX <> 'yes'
AND oppo.textValue NOT LIKE '%UserUploads%'
AND oppo.textValue NOT LIKE '%//canvas%'
AND oppo.textValue NOT LIKE '//houseofmagnets.com%'
AND oppo.textValue NOT LIKE 'https://rembrandt.houseofmagnets%'
AND oppo.textValue NOT LIKE '//www.houseofmagnets.com/images/business-card-backs%'
AND oppo.textValue NOT LIKE '/webstores/BusinessCards/StaticBacks/%'
AND op.processType = 'fasTrak'
--AND o.orderStatus NOT IN ('Failed', 'Cancelled')
AND o.orderStatus IN ('Delivered', 'In Transit', 'In Transit USPS')
AND (
		--BC
		SUBSTRING(op.productCode, 1, 2) = 'BP' 
		 OR
		--NC
		SUBSTRING(op.productCode, 1, 2) = 'NC'
				AND SUBSTRING(op.productCode, 3, 2) <> 'EV'
		--QC
		OR SUBSTRING(op.productCode, 3, 2) = 'QC'
				AND SUBSTRING(op.productCode, 1, 2) IN
							(SELECT productCode
							FROM tblSwitch_productCodes))
*/