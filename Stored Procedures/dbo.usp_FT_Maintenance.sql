CREATE PROC [dbo].[usp_FT_Maintenance]
AS
SET NOCOUNT ON;

BEGIN TRY
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/26/14
-- Purpose     Maintenance code for fasTrak related products				
-------------------------------------------------------------------------------
-- Modification History
-- 08/26/16			Added FC related code throughout.
-- 10/04/16			Commented out fastTrack_status updates now that we are using the field to drive production.
-- 10/28/16			Updated FC related code throughout to pull out the oddity "NCFC%" that actually isn't a fasTrak product.
-- 12/08/16			Added maintenance section at the end of sproc that accounts for other similiar, although not necessarily FT related, maintenance issues.
-- 02/01/17			Pulled out NCCU-01 from productType assignation near LN 110.
-- 03/23/17			Added CCRG namebadges to exception list for FT assignation, jf.
-- 08/09/17			Added JU/EX/BU FT code, jf
-- 08/09/17			Added subquery to QM/QC and FC, jf.
-- 09/21/17			Added missing JU/EX/BU/NC FT tblOrders_Products updates, denoted with (#), jf.
-- 09/28/17			Added NC FT section at top. [removed], jf
-- 04/10/18			Added GNCC and GNCH to FT sections, denoted with (###), jf.
-- 07/18/18			Update code syntax throughout, jf
-- 07/18/18			Added processType = 'fasTrak' when fasTrak_status = 'good to go' on an OPID, jf.
-- 07/24/18			Added the following code to allow badges to go thru. Originally was in MIGLIVE. Will likely remove once IMAGE/IMPO fixed, jf:
																		--UPDATE tblOrders_Products
																		--SET fastTrak_ProductType = 'Badge'
																		--WHERE productCode LIKE 'NB%'
																		--AND fastTrak_ProductType IS NULL
--05/06/19			Made the fasttrak_status update agnostic to productType, since we now use that field for the status custom products that get pick-n-printed, or otherwise make an FT flow, jf.
--05/06/19			Adjust the code in the note above this one, from 'AND DATEDIFF(DD, a.orderDate, GETDATE()) < 700' to 'AND DATEDIFF(DD, a.orderDate, GETDATE()) > 90'
--11/26/19			Updated G2G section to exclude certain FA product lines from being updated to a FT status.
--02/17/20			CB, combined update statements for tblProducts and tblOrders_Products to reduce blocking and deadlocking
--02/18/20			CB, comvined update statements from line 1027 down to reduce blocking and deadlocking
--11/12/20			JF, removed imprintName code at the bottom of the proc as per Cherilyn's demands. Near LN915.
--04/27/21			CKB, Markful
--08/18/21			BJS, Delivered can't be completed when it is resubmitted
-------------------------------------------------------------------------------

/* Extra Notes			
					
					GOING TICKETLESS ON PRODUCTLINES (thus, moving product lines to the fasTrak)
					When asked to add a product line like "First Class" to ticketless, we're basically adding that product line to the
					fasTrak. Here's the steps to complete that prior to modifying any sprocs:		
					
					1. Update the necessary fields in tblProducts like so (using First Class as an example):

								UPDATE tblProducts
								SET 
								productType = 'fasTrak',
								fastTrak = 1,
								fastTrak_productType = 'CM'
								WHERE
								SUBSTRING(productCode, 1, 2) = 'CM' 
								AND productCode <> 'CMJU00-01'	
					
					2. Update this sproc throughout to match that of other ticketless product lines. Basically, copy an existing section and 
					update it with the new productCode details.

					3.	Update MIG_HOMLIVE which is responsible for correctly assigning processType per OPID as they come in.
					You will do this in 2 places: Near LINE 463 and near LINE 400 (this might change as the sproc grows/shrinks over time).
					
					4. Update usp_FT_getActive_Sort, which is the sproc responsible for presenting data on http://intranet/gbs/admin/orders_fasTrak.asp
					This is done in 1 place, near LINE 57 (which again, might change as the sproc changes shape over time).

					5. If products are not showing up on the page above, it may be due to the product line previously coming in as "Stock".
					This issue should be fixed already in MIG_HOMLIVE near LINE 463, but if for some reason you run into problems, confirm that
					this area of code is working properly.
*/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- [A] tblProducts Updates ------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- This section updates the Product Catalog with fastTrak_productType values should they have been imported poorly due to human error, or if something was just missed.
-- this section will get updated periodically with random productCode exceptions (e.g. products that are badges however they don't go thru fasTrak)

	---- GLOBAL:
	--UPDATE tblProducts
	--SET fastTrak = 0, fastTrak_productType = NULL
	--WHERE productType IN ('Custom', 'Stock')

	---- BADGE:
	--UPDATE tblProducts
	--SET fastTrak = 0, fastTrak_productType = NULL
	--WHERE productCode LIKE 'NBCU%'
	--OR productCode LIKE 'FM%'
	--OR productCode = 'NB00SU-001'
	--OR SUBSTRING(productCode, 1, 6) = 'NB00MB'
	--OR SUBSTRING(productCode, 6, 1) = 'F' --(Western & Southern Life Magnetic Name Badges (#NBWFBF-001-100))

	---- BADGE: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'Name Badge'
	--WHERE fastTrak = 0
	--AND productCode LIKE 'NB%'
	--AND productCode NOT LIKE 'NBCU%'
	--AND productCode NOT IN ('NB00SU-001','NB2COB-001-100', 'NB2COB-002-100', 'NB2CRB-001-100', 'NB2CRB-002-100')
	--AND SUBSTRING(productCode, 1, 6) <> 'NB00MB'
	--AND SUBSTRING(productCode, 6, 1) <> 'F'

	---- QC: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'QuickCard'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 3, 2) = 'QC'
	--AND SUBSTRING(productCode, 1, 2) IN
	--				(SELECT productCode
	--				FROM tblSwitch_productCodes)

	---- QM: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'QM'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 3, 2) = 'QM'
	--AND SUBSTRING(productCode, 1, 2) IN
	--				(SELECT productCode
	--				FROM tblSwitch_productCodes)

	---- CACX: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'CACX'
	--WHERE fastTrak = 0
	--AND (SUBSTRING(productCode, 1, 4) = 'CACC' 
	--		OR SUBSTRING(productCode, 1, 4) = 'CACH')

	---- FC: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'FC'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 3, 2) = 'FC'
	--AND SUBSTRING(productCode, 1, 2) IN
	--				(SELECT productCode
	--				FROM tblSwitch_productCodes)

	---- NC: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'NC'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 1, 2) = 'NC'
	--AND SUBSTRING(productCode, 3, 2) <> 'EV'
	--AND productType IN ('fasTrak')
	--AND productCode <> 'NCCU-01'

	---- PEN: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'Pen'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 1, 2) = 'PN'

	---- CM: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'CM'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 1, 2) = 'CM'

	---- JU: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'JU'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 3, 2) = 'JU' 
	--AND SUBSTRING(productCode, 1, 2) IN
	--				(SELECT productCode
	--				FROM tblSwitch_productCodes)

	---- EX: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'EX'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 3, 2) = 'EX' 
	--AND SUBSTRING(productCode, 1, 2) IN
	--				(SELECT productCode
	--				FROM tblSwitch_productCodes)

	---- BU: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'BU'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 3, 2) = 'BU' 
	--AND SUBSTRING(productCode, 1, 2) IN
	--				(SELECT productCode
	--				FROM tblSwitch_productCodes)

	---- GNCC/GNCH: update products to FT
	--UPDATE tblProducts
	--SET fastTrak = 1, fastTrak_productType = 'GN'
	--WHERE fastTrak = 0
	--AND SUBSTRING(productCode, 1, 4) IN ('GNCC', 'GNCH') 
	--AND SUBSTRING(productCode, 1, 2) IN
	--				(SELECT productCode
	--				FROM tblSwitch_productCodes)

/*********************New product updates************************************************************************/

declare @tblProducts_Update table
(
productID int primary key
,faskTrak bit
,fastTrak_productType varchar(50)
)

-- GLOBAL:
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 0, fastTrak_productType = null
from dbo.tblProducts p
WHERE p.productType IN ('Custom', 'Stock')
	and (p.fastTrak <> 0 or p.fastTrak_productType is not NULL)

-- BADGE:
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 0, fastTrak_productType = null
from dbo.tblProducts p
WHERE (productCode LIKE 'NBCU%'
		OR productCode LIKE 'FM%'
		OR productCode = 'NB00SU-001'
		OR SUBSTRING(productCode, 1, 6) = 'NB00MB'
		OR SUBSTRING(productCode, 6, 1) = 'F') --(Western & Southern Life Magnetic Name Badges (#NBWFBF-001-100))
	and (p.fastTrak <> 0 or p.fastTrak_productType is not NULL)
	and not exists (select productID from @tblProducts_Update pu where p.productID = pu.productID)

-- BADGE: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'Name Badge'
from dbo.tblProducts p
WHERE p.productCode LIKE 'NB%'
	AND p.productCode NOT LIKE 'NBCU%'
	AND p.productCode NOT IN ('NB00SU-001','NB2COB-001-100', 'NB2COB-002-100', 'NB2CRB-001-100', 'NB2CRB-002-100')
	AND (p.productCode NOT LIKE 'NB__S%' OR p.productCode LIKE 'NB___U%')
	AND SUBSTRING(p.productCode, 1, 6) <> 'NB00MB'
	AND SUBSTRING(p.productCode, 6, 1) <> 'F'
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'Name Badge'))

-- QC: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'QuickCard'
from dbo.tblProducts p
WHERE SUBSTRING(p.productCode, 3, 2) = 'QC'
	AND SUBSTRING(p.productCode, 1, 2) IN
					(SELECT productCode
					FROM tblSwitch_productCodes)
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'QuickCard'))

-- QM: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'QM'
from dbo.tblProducts p
WHERE SUBSTRING(p.productCode, 3, 2) = 'QM'
	AND SUBSTRING(p.productCode, 1, 2) IN
					(SELECT productCode
					FROM tblSwitch_productCodes)
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'QM'))

-- CACX: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'CACX'
from dbo.tblProducts p
WHERE (SUBSTRING(p.productCode, 1, 4) = 'CACC' 
			OR SUBSTRING(p.productCode, 1, 4) = 'CACH')
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'CACX'))

-- FC: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'FC'
from dbo.tblProducts p
WHERE SUBSTRING(p.productCode, 3, 2) = 'FC'
	AND SUBSTRING(p.productCode, 1, 2) IN
					(SELECT productCode
					FROM tblSwitch_productCodes)
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'FC'))

-- NC: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'NC'
from dbo.tblProducts p
WHERE SUBSTRING(p.productCode, 1, 2) = 'NC'
	AND SUBSTRING(p.productCode, 3, 2) <> 'EV'
	AND productType IN ('fasTrak')
	AND productCode <> 'NCCU-01'
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'NC') or p.fastTrak_productType is null)

-- PEN: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'Pen'
from dbo.tblProducts p
WHERE SUBSTRING(p.productCode, 1, 2) = 'PN'
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'Pen') or p.fastTrak_productType is null)

	-- CM: update products to FT
--UPDATE tblProducts
--SET fastTrak = 1, fastTrak_productType = 'CM'
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'CM'
from dbo.tblProducts p
WHERE SUBSTRING(p.productCode, 1, 2) = 'CM'
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'CM') or p.fastTrak_productType is null)

-- JU: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'JU'
from dbo.tblProducts p
WHERE SUBSTRING(p.productCode, 3, 2) = 'JU' 
	AND SUBSTRING(p.productCode, 1, 2) IN
					(SELECT productCode
					FROM tblSwitch_productCodes)
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'JU') or p.fastTrak_productType is null)

-- EX: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'EX'
from dbo.tblProducts p
WHERE fastTrak = 0
	AND SUBSTRING(productCode, 3, 2) = 'EX' 
	AND SUBSTRING(productCode, 1, 2) IN
					(SELECT productCode
					FROM tblSwitch_productCodes)
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'EX') or p.fastTrak_productType is null)

-- BU: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'BU'
--,p.fastTrak, p.fastTrak_productType
from dbo.tblProducts p
WHERE p.fastTrak = 0 and  SUBSTRING(productCode, 3, 2) = 'BU' 
	AND SUBSTRING(productCode, 1, 2) IN
					(SELECT productCode
					FROM tblSwitch_productCodes)
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'BU') or p.fastTrak_productType is null)

-- GNCC/GNCH: update products to FT
insert into @tblProducts_Update(productID,faskTrak,fastTrak_productType)
select p.productID, fastTrak = 1, fastTrak_productType = 'GN'
from dbo.tblProducts p
WHERE SUBSTRING(productCode, 1, 4) IN ('GNCC', 'GNCH') 
	AND SUBSTRING(productCode, 1, 2) IN
					(SELECT productCode
					FROM tblSwitch_productCodes)
	and (p.fastTrak <> 1 or (p.fastTrak_productType is not null and p.fastTrak_productType <> 'GN') or p.fastTrak_productType is null)

update p
set fastTrak = pu.faskTrak, fastTrak_productType = pu.fastTrak_productType
from tblProducts p
inner join @tblProducts_Update pu
	on p.productID = pu.productID

declare @tblProducts_shortName_Update table
(productId int, shortName nvarchar(150))

insert into @tblProducts_shortName_Update (productId,shortName)
select p.productID, shortName = RTRIM(SUBSTRING(p.productName,1,(SELECT CHARINDEX('(', p.productName)-1)))
from tblProducts p
WHERE (p.shortName is NULL OR p.shortName = '')
	AND p.fastTrak_productType = 'Name Badge'

insert into @tblProducts_shortName_Update (productId,shortName)
select p.productID, shortName = REPLACE(p.shortName,(SUBSTRING(p.shortName,1,(SELECT CHARINDEX('-', p.productName)+1))),'')
from tblProducts p
WHERE p.shortName like '%-%'
	AND p.shortName IS NOT NULL
	AND p.fastTrak_productType = 'Name Badge'

update p
set shortName = pu.shortName
from tblProducts p
inner join @tblProducts_shortName_Update pu
	on p.productID = pu.productID

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- [B] tblOrders_Products Updates ------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---- BADGE: update FT-class products to the FT where applicable
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'Name Badge')

	--UPDATE tblOrders_Products
	--SET fastTrak_ProductType = 'Badge'
	--WHERE productCode LIKE 'NB%'
	--AND fastTrak_ProductType IS NULL

	---- QC: update FT-class products to the FT where applicable, QCs have the added requirement of being non "pick-n-print" orders.
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'QuickCard')
	--AND [ID] IN
	--	(SELECT ordersProductsID
	--	FROM tblOrdersProducts_productOptions
	--	WHERE deleteX <> 'yes'
	--	AND optionCaption = 'OPC')

	---- QC: Fix QCs that may've been marked fasTrak but are now actually pick-n-print
	--UPDATE tblOrders_Products
	--SET fastTrak = 0
	--WHERE (fastTrak = 1 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'QuickCard')
	--AND [ID] NOT IN
	--	(SELECT ordersProductsID
	--	FROM tblOrdersProducts_productOptions
	--	WHERE deleteX <> 'yes'
	--	AND optionCaption = 'OPC')

	---- QM: update FT-class products to the FT where applicable, QMs have the added requirement of being non "pick-n-print" orders.
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'QM')
	--AND [ID] IN
	--	(SELECT ordersProductsID
	--	FROM tblOrdersProducts_productOptions
	--	WHERE deleteX <> 'yes'
	--	AND optionCaption = 'OPC')

	---- MC: Fix QMs that may've been marked fasTrak but are now actually pick-n-print
	--UPDATE tblOrders_Products
	--SET fastTrak = 0
	--WHERE (fastTrak = 1 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'QM')
	--AND [ID] NOT IN
	--	(SELECT ordersProductsID
	--	FROM tblOrdersProducts_productOptions
	--	WHERE deleteX <> 'yes'
	--	AND optionCaption = 'OPC')

	---- CACX: update FT-class products to the FT where applicable, CACXs have the added requirement of being non "pick-n-print" orders.
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'CACX')
	--AND [ID] IN
	--	(SELECT ordersProductsID
	--	FROM tblOrdersProducts_productOptions
	--	WHERE deleteX <> 'yes'
	--	AND optionCaption = 'OPC')

	---- CACX: Fix CACXs that may've been marked fasTrak but are now actually pick-n-print
	--UPDATE tblOrders_Products
	--SET fastTrak = 0
	--WHERE (fastTrak = 1 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'CACX')
	--AND [ID] NOT IN
	--	(SELECT ordersProductsID
	--	FROM tblOrdersProducts_productOptions
	--	WHERE deleteX <> 'yes'
	--	AND optionCaption = 'OPC')

	---- PEN: update FT-class products to the FT where applicable
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'Pen')

	---- CM: update FT-class products to the FT where applicable
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'CM')

	---- FC: update FT-class products to the FT where applicable, FCs have the added requirement of being non "pick-n-print" orders.
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'FC'
	--	AND SUBSTRING(productCode, 1, 2) <> 'NC')
	--AND [ID] IN
	--	(SELECT ordersProductsID
	--	FROM tblOrdersProducts_productOptions
	--	WHERE deleteX <> 'yes'
	--	AND optionCaption = 'OPC')

	---- FC: Fix FCs that may've been marked fasTrak but are now actually pick-n-print
	--UPDATE tblOrders_Products
	--SET fastTrak = 0
	--WHERE (fastTrak = 1 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'FC')
	--AND [ID] NOT IN
	--	(SELECT ordersProductsID
	--	FROM tblOrdersProducts_productOptions
	--	WHERE deleteX <> 'yes'
	--	AND optionCaption = 'OPC')

	---- BU: update FT-class products to the FT where applicable (#)
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'BU')

	---- EX: update FT-class products to the FT where applicable (#)
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'EX')

	---- JU: update FT-class products to the FT where applicable (#)
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'JU')

	---- NC: update FT-class products to the FT where applicable (#)
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'NC')

	---- GNCC/GNCH: update FT-class products to the FT where applicable (###)
	--UPDATE tblOrders_Products
	--SET fastTrak = 1
	--WHERE (fastTrak = 0 OR fastTrak IS NULL)
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 1
	--	AND fastTrak_productType = 'GN')

/*********New tblOrders_Products updates*****************************************************************/
UPDATE tblOrders_Products
SET fastTrak_ProductType = 'Badge'
WHERE productCode LIKE 'NB%'
	AND fastTrak_ProductType IS NULL

declare @tblOrders_Products_FastTrack_Update table
(
ID int primary key
,fastTrak bit
)

-- BADGE: update FT-class products to the FT where applicable
insert into @tblOrders_Products_FastTrack_Update (ID,fastTrak)
select op.ID, fastTrak = 1
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 0 OR op.fastTrak IS NULL)
	and exists
		(select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'Name Badge' and op.productID = p.productID)

-- QC: update FT-class products to the FT where applicable, QCs have the added requirement of being non "pick-n-print" orders.
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 0 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'QuickCard' and op.productID = p.productID)
	and exists (select top 1 1 from tblOrdersProducts_productOptions oppo where oppo.deletex <> 'yes' and optionCaption = 'OPC' and op.ID = oppo.ordersProductsID)) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- QC: Fix QCs that may've been marked fasTrak but are now actually pick-n-print
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 0
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 1 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'QuickCard' and op.productID = p.productID)
	and not exists (select top 1 1 from tblOrdersProducts_productOptions oppo where oppo.deletex <> 'yes' and optionCaption = 'OPC' and op.ID = oppo.ordersProductsID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- QM: update FT-class products to the FT where applicable, QMs have the added requirement of being non "pick-n-print" orders.
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 0 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'QM' and op.productID = p.productID)
	and exists (select top 1 1 from tblOrdersProducts_productOptions oppo where oppo.deletex <> 'yes' and optionCaption = 'OPC' and op.ID = oppo.ordersProductsID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- MC: Fix QMs that may've been marked fasTrak but are now actually pick-n-print
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 0
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 1 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'QM' and op.productID = p.productID)
	and not exists (select top 1 1 from tblOrdersProducts_productOptions oppo where oppo.deletex <> 'yes' and optionCaption = 'OPC' and op.ID = oppo.ordersProductsID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- CACX: update FT-class products to the FT where applicable, CACXs have the added requirement of being non "pick-n-print" orders.
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 0 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'CACX' and op.productID = p.productID)
	and exists (select top 1 1 from tblOrdersProducts_productOptions oppo where oppo.deletex <> 'yes' and optionCaption = 'OPC' and op.ID = oppo.ordersProductsID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- CACX: Fix CACXs that may've been marked fasTrak but are now actually pick-n-print
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 0
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 1 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'CACX' and op.productID = p.productID)
	and not exists (select top 1 1 from tblOrdersProducts_productOptions oppo where oppo.deletex <> 'yes' and optionCaption = 'OPC' and op.ID = oppo.ordersProductsID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- PEN: update FT-class products to the FT where applicable
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 0 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'Pen' and op.productID = p.productID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- CM: update FT-class products to the FT where applicable
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 0 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'CM' and op.productID = p.productID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- FC: update FT-class products to the FT where applicable, FCs have the added requirement of being non "pick-n-print" orders.
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (op.fastTrak = 0 OR op.fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'FC' and SUBSTRING(p.productCode, 1, 2) <> 'NC' and op.productID = p.productID)
	and exists (select top 1 1 from tblOrdersProducts_productOptions oppo where oppo.deletex <> 'yes' and optionCaption = 'OPC' and op.ID = oppo.ordersProductsID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- FC: Fix FCs that may've been marked fasTrak but are now actually pick-n-print
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 0
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (fastTrak = 1 OR fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'FC' and op.productID = p.productID)
	and not exists (select top 1 1 from tblOrdersProducts_productOptions oppo where oppo.deletex <> 'yes' and optionCaption = 'OPC' and op.ID = oppo.ordersProductsID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- BU: update FT-class products to the FT where applicable (#)
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (fastTrak = 0 OR fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'BU' and op.productID = p.productID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- EX: update FT-class products to the FT where applicable (#)
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (fastTrak = 0 OR fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'EX' and op.productID = p.productID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- JU: update FT-class products to the FT where applicable (#)
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (fastTrak = 0 OR fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'JU' and op.productID = p.productID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- NC: update FT-class products to the FT where applicable (#)
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE (fastTrak = 0 OR fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'NC' and op.productID = p.productID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- GNCC/GNCH: update FT-class products to the FT where applicable (###)
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 1
from dbo.tblOrders_Products op
WHERE (fastTrak = 0 OR fastTrak IS NULL)
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 1 and p.fastTrak_productType = 'GN' and op.productID = p.productID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

-- revoke FT-class products where applicable (i.e. products demoted from FT)
merge into @tblOrders_Products_FastTrack_Update as t
using (
select op.ID, fastTrak = 0
--,op.fastTrak
from dbo.tblOrders_Products op
WHERE fastTrak = 1
	and exists (select top 1 1 from tblProducts p where p.fastTrak = 0 and op.productID = p.productID)
) as s
	on t.ID = s.ID
when not matched by target then 
	insert(ID,fastTrak)
	values(s.ID,s.fastTrak)
when matched then
	update set t.fastTrak = s.fastTrak
;

update op
set fastTrak = opfu.fastTrak
from dbo.tblOrders_Products op
inner join @tblOrders_Products_FastTrack_Update opfu
	on op.ID = opfu.ID

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- [C] Misc Work
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	---- revoke FT-class products where applicable (i.e. products demoted from FT)
	--UPDATE tblOrders_Products
	--SET fastTrak = 0
	--WHERE fastTrak = 1
	--AND productID IN
	--	(SELECT productID 
	--	FROM tblProducts 
	--	WHERE fastTrak = 0)

	----//update Imprint Name
	--UPDATE tblOrders_Products
	--SET fastTrak_imprintName = ''
	--WHERE fastTrak_imprintName IS NULL
	--AND fastTrak = 1

	--UPDATE tblOrders_Products
	--SET fastTrak_imprintName = b.textValue
	--FROM tblOrders_Products a 
	--INNER JOIN tblOrdersProducts_productOptions b
	--	ON a.[ID] = b.ordersProductsID
	--INNER JOIN tblOrders o
	--	ON a.orderID = o.orderID
	--WHERE 
	--(b.optionID = 279 OR b.optionID = 245)
	--AND b.deleteX <> 'yes'
	--AND a.fastTrak_completed = 0
	--AND a.fastTrak_status NOT IN ('Completed', 'Pending')
	--AND a.fastTrak = 1
	--AND a.deleteX <> 'yes'
	--AND o.orderStatus NOT IN('Failed', 'Cancelled')
	--AND o.orderStatus NOT LIKE '%Waiting%'
	--AND a.fastTrak_imprintName <> b.textValue

--removed on 11/12/20; jf.
--update op
--set fastTrak_imprintName = a.fastTrak_imprintName
--from dbo.tblOrders_Products op
--inner join 
--(select op.ID, op.fastTrak_imprintName
--from dbo.tblOrders_Products op
--where op.fastTrak_imprintName IS NULL
--	AND op.fastTrak = 1
--union
--select op.ID, op.fastTrak_imprintName
--FROM tblOrders_Products op 
--INNER JOIN tblOrdersProducts_productOptions oppo
--	ON op.[ID] = oppo.ordersProductsID
--INNER JOIN tblOrders o
--	ON op.orderID = o.orderID
--WHERE 
--	oppo.optionID in (279,245)
--	AND oppo.deleteX <> 'yes'
--	AND op.fastTrak_completed = 0
--	AND op.fastTrak_status NOT IN ('Completed', 'Pending')
--	AND op.fastTrak = 1
--	AND op.deleteX <> 'yes'
--	AND o.orderStatus NOT IN('Failed', 'Cancelled')
--	AND o.orderStatus NOT LIKE '%Waiting%'
--	AND op.fastTrak_imprintName <> oppo.textValue
--) a
--on op.ID = a.ID


	---- update product shortNames
	--UPDATE tblProducts
	--SET shortName = RTRIM(SUBSTRING(productName,1,(SELECT CHARINDEX('(', productName)-1)))
	--WHERE (shortName is NULL OR shortName = '')
	--AND fastTrak_productType = 'Name Badge'

	--UPDATE tblProducts
	--SET shortName = REPLACE(shortName,(SUBSTRING(shortName,1,(SELECT CHARINDEX('-', productName)+1))),'')
	--WHERE shortName like '%-%'
	--AND shortName IS NOT NULL
	--AND fastTrak_productType = 'Name Badge'

	---- update FT statuses where applicable
	--UPDATE tblOrders_Products
	--SET fastTrak_status = 'In House', 
	--fastTrak_status_LastModified = getDate()
	--FROM tblOrders_Products op
	--INNER JOIN tblOrders a
	--	ON a.orderID = op.orderID
	--WHERE fastTrak_status IS NULL
	--AND a.orderStatus = 'In House'
	--AND fastTrak = 1

	--UPDATE tblOrders_Products
	--SET fastTrak_status = 'In Production', 
	--fastTrak_status_LastModified = getDate()
	--FROM tblOrders_Products op
	--INNER JOIN tblOrders a
	--	ON a.orderID = op.orderID
	--WHERE fastTrak_status IS NULL
	--AND a.orderStatus = 'In Production'
	--AND fastTrak = 1

	----this section updates all OPIDS (fastTrak agnostic)
	--UPDATE tblOrders_Products
	--SET fastTrak_status = 'Completed', 
	--fastTrak_status_LastModified = GETDATE() --select op.ID
	--FROM tblOrders_Products op
	--INNER JOIN tblOrders a ON a.orderID = op.orderID
	--WHERE fastTrak_status <> 'Completed'
	--AND (a.orderStatus = 'Delivered' OR a.orderStatus LIKE '%Transit%')
	--AND DATEDIFF(DD, a.orderDate, GETDATE()) > 90

declare @tblOrders_Products_fastTrack_status_Update table
(ID int, fastTrack_status varchar(50), fastTrak_status_lastModified datetime)

insert into @tblOrders_Products_fastTrack_status_Update (ID,fastTrack_status,fastTrak_status_lastModified)
select op.ID, fastTrak_status = 'In House', fastTrak_status_LastModified = getDate()
FROM tblOrders_Products op
INNER JOIN tblOrders o
	ON o.orderID = op.orderID
WHERE op.fastTrak_status IS NULL
	AND o.orderStatus = 'In House'
	AND op.fastTrak = 1

insert into @tblOrders_Products_fastTrack_status_Update (ID,fastTrack_status,fastTrak_status_lastModified)
select op.ID, fastTrak_status = 'In Production', fastTrak_status_LastModified = getDate()
FROM tblOrders_Products op
INNER JOIN tblOrders o
	ON o.orderID = op.orderID
WHERE op.fastTrak_status IS NULL
	AND o.orderStatus = 'In Production'
	AND op.fastTrak = 1

	--this section updates all OPIDS (fastTrak agnostic)
insert into @tblOrders_Products_fastTrack_status_Update (ID,fastTrack_status,fastTrak_status_lastModified)
select op.ID, fastTrak_status = 'Completed', fastTrak_status_LastModified = GETDATE() --select op.ID
FROM tblOrders_Products op
INNER JOIN tblOrders o 
	ON o.orderID = op.orderID
WHERE fastTrak_status <> 'Completed'
	AND (o.orderStatus = 'Delivered' OR o.orderStatus LIKE '%Transit%')
	AND DATEDIFF(DD, o.orderDate, GETDATE()) > 90
	AND op.fastTrak_resubmit <> 1


update op
set fastTrak_status = opfsu.fastTrack_status, fastTrak_status_LastModified = opfsu.fastTrak_status_lastModified
from dbo.tblOrders_Products op
inner join @tblOrders_Products_fastTrack_status_Update opfsu
	on op.ID = opfsu.ID

---- update FT completion flags
--UPDATE op
--SET fastTrak_completed = 1
--from tblOrders_Products op
--WHERE op.fastTrak_status = 'Completed'
--	AND op.fastTrak = 1
--	AND op.fastTrak_resubmit <> 1
--	AND op.fastTrak_completed = 0

--UPDATE op
--SET fastTrak_completedOn = fastTrak_status_lastModified
--from tblOrders_Products op
--WHERE op.fastTrak_completedOn IS NULL
--	AND op.fastTrak = 1
--	AND op.fastTrak_completed = 1
--	and isnull(op.fastTrak_completedOn,1) <> isnull(op.fastTrak_status_lastModified,1)

---- update fasTrak items to completed, where applicable and not previously marked completed via FT tab
--UPDATE op
--SET fastTrak_completed = 1
--from tblOrders_Products op
--WHERE op.processType = 'fasTrak'
--	AND op.fastTrak_completed = 0
--	and exists (select top 1 1 from tblOrders o where op.orderID = o.orderID and (o.orderStatus = 'Delivered' OR orderStatus = 'ON HOM Dock' OR orderStatus LIKE '%transit%'))

declare @tblOrders_Products_fastTrak table
(ID int, fastTrak_completed bit, fastTrak_completedOn datetime, processType varchar(50))

--UPDATE op
--SET fastTrak_completed = 1
insert into @tblOrders_Products_fastTrak (ID,fastTrak_completed,fastTrak_completedOn,processType)
select op.ID, fastTrak_completed = 1, op.fastTrak_completedOn, op.processType
from tblOrders_Products op
WHERE op.fastTrak_status = 'Completed'
	AND op.fastTrak = 1
	AND op.fastTrak_resubmit <> 1
	AND op.fastTrak_completed = 0

insert into @tblOrders_Products_fastTrak (ID,fastTrak_completed,fastTrak_completedOn,processType)
select op.ID, op.fastTrak_completed, op.fastTrak_status_lastModified, op.processType
from tblOrders_Products op
WHERE op.fastTrak_completedOn IS NULL
	AND op.fastTrak = 1
	AND op.fastTrak_completed = 1
	and isnull(op.fastTrak_completedOn,1) <> isnull(op.fastTrak_status_lastModified,1)

-- update fasTrak items to completed, where applicable and not previously marked completed via FT tab
insert into @tblOrders_Products_fastTrak (ID,fastTrak_completed,fastTrak_completedOn,processType)
select op.ID, fastTrak_completed = 1, op.fastTrak_completedOn, op.processType
from tblOrders_Products op
WHERE op.processType = 'fasTrak'
	AND op.fastTrak_completed = 0
	and exists (select top 1 1 from tblOrders o where op.orderID = o.orderID and (o.orderStatus = 'Delivered' OR orderStatus = 'ON HOM Dock' OR orderStatus = 'ON MRK Dock' OR orderStatus LIKE '%transit%'))

-- Change processType = 'fasTrak' when fasttrak_status is updated to 'good to go'. 11/26/19; we want to ignore certain products that should never be FT, as shown in last two clauses
insert into @tblOrders_Products_fastTrak (ID,fastTrak_completed,fastTrak_completedOn,processType)
select op.ID, op.fastTrak_completed, op.fastTrak_completedOn, processType = 'fasTrak'
FROM tblOrders_Products op
INNER JOIN tblOrders o 
	ON o.orderID = op.orderID
WHERE op.fastTrak_status = 'Good to Go'
	AND (op.processType <> 'fasTrak'
			OR op.processType IS NULL)
	AND SUBSTRING(op.productCode, 1, 4) NOT IN ('PLFA', 'EVFA', 'LHFA', 'BMFA')
	AND SUBSTRING(op.productCode, 1, 2) NOT IN ('SN')
	AND (op.productCode NOT LIKE 'NB__S%' OR op.productCode LIKE 'NB___U%')
	
update op
set fastTrak_completed = opf.fastTrak_completed, fastTrak_completedOn = opf.fastTrak_completedOn, processType = opf.processType
from dbo.tblOrders_Products op
inner join @tblOrders_Products_fastTrak opf
	on op.ID = opf.ID


	-- update FT Tab values
	UPDATE tblTabCount
	SET fasttrak_active = 
		(SELECT COUNT(DISTINCT(op.[id]))
		FROM tblOrders a 
		INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
		INNER JOIN tblCustomers c ON a.customerID = c.customerID
		INNER JOIN tblProducts p ON op.productID = p.productID
		WHERE op.processType = 'fasTrak'
		AND op.deleteX <> 'Yes'
		AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'Delivered', 'MIGZ', 'In Transit', 'In Transit USPS', 'Waiting For Payment', 
								'Waiting On Customer', 'Waiting For New Art', 'GTG-Waiting For Payment')
		AND op.fastTrak_status NOT IN ('Completed', 'Pending')
		AND op.fastTrak_completed = 0
		AND (op.fastTrak_imprintName NOT LIKE '%Spreadsheet%' 
				AND op.fastTrak_imprintName NOT LIKE '%email%'
				OR op.fastTrak_imprintName IS NULL)
		)

	UPDATE tblTabCount
	SET fasttrak_completed = 
			(SELECT COUNT(ID)
			FROM tblOrders_products
			WHERE fastTrak = 1
					AND fastTrak_completed = 1
					AND deleteX <> 'Yes')

	-- update notes to production notes where author is Switch.
	update tbl_notes
	SET notesType = 'product'
	where author = 'Switch'
	and notesType <> 'product'

	-- update Pens-related subcontract values
	UPDATE tblProducts
	SET subcontract = 1
	WHERE
	SUBSTRING(productCode, 1, 2) = 'PN' 
	AND subContract <> 1

	---- Change processType = 'fasTrak' when fasttrak_status is updated to 'good to go'. 11/26/19; we want to ignore certain products that should never be FT, as shown in last two clauses
	--UPDATE op
	--SET processType = 'fasTrak'
	--FROM tblOrders_Products op
	--INNER JOIN tblOrders o ON o.orderID = op.orderID
	--WHERE op.fastTrak_status = 'Good to Go'
	--AND (op.processType <> 'fasTrak'
	--		OR op.processType IS NULL)
	--AND SUBSTRING(op.productCode, 1, 4) NOT IN ('PLFA', 'EVFA', 'LHFA', 'BMFA')
	--AND SUBSTRING(op.productCode, 1, 2) NOT IN ('SN')

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH