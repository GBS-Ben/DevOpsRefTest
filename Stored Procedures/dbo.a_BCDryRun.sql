CREATE PROCEDURE "dbo"."a_BCDryRun"

AS
SELECT DISTINCT op.ID, GETDATE(), a.orderno, a.orderdate, a.orderstatus, op.fasttrak_status
FROM tblOrders a
INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
INNER JOIN tblOrders_Products op ON a.orderID = op.orderID
INNER JOIN tblProducts p ON op.productID = p.productID
INNER JOIN tblOrdersProducts_productOptions oppo ON op.ID = oppo.ordersProductsID
INNER JOIN tblOPPO_fileExists x ON oppo.PKID = x.PKID
WHERE

--1. Duplex Designation ----------------------------------
op.ID IN
--This subquery shows DUPLEX OPIDs
(SELECT ordersProductsID
FROM tblOrdersProducts_productOptions
WHERE deleteX <> 'yes'
AND (
   --Regular Duplex BCs
   optionCaption IN ('Product Back', 'Back Intranet PDF')
  OR
   -- CYO Duplex BCs
   optionCaption IN ('File Name 1', 'File Name 2')
   AND textValue NOT LIKE '%/%'
   AND textValue LIKE '%-BACK-%'
  )
AND textValue NOT IN
 ('/webstores/BusinessCards/StaticBacks/BLANK-HORZ.PDF', 
  '/webstores/BusinessCards/StaticBacks/BLANK-VERT.PDF',
  '\\Arc\Archives\Webstores\BusinessCards\BLANK-HORZ.PDF', 
  '\\Arc\Archives\Webstores\BusinessCards\BLANK-VERT.PDF', 
  'BLANK')
AND ordersProductsID NOT IN
 --Blank Backs
 (SELECT ordersProductsID
 FROM tblOrdersProducts_productOptions
 WHERE deleteX <> 'yes'
 AND optionID = 564)
)

--2. Order Qualification ----------------------------------
AND DATEDIFF(MI, a.created_on, GETDATE()) > 10
AND a.orderDate > CONVERT(DATETIME, '02/01/2018')
AND a.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
AND a.displayPaymentStatus = 'Good'

--3. Product Qualification ----------------------------------
AND SUBSTRING(p.productCode, 1, 2) = 'BP' 

--4. OPID Qualification ----------------------------------
AND op.deleteX <> 'yes'
AND op.processType = 'fasTrak'
AND (
 --4.a
 op.fastTrak_status = 'In House'
 AND op.switch_create = 0 
 AND op.[ID] IN
   (SELECT ordersProductsID
   FROM tblOrdersProducts_productOptions
   WHERE deleteX <> 'yes'
   AND optionCaption = 'OPC')
 --4.b
 OR op.fastTrak_status = 'Good to Go'
 --4.c
 OR op.fastTrak_resubmit = 1
 )
AND op.[ID] NOT IN
(SELECT ordersProductsID
FROM tblOrdersProducts_productOptions
WHERE deleteX <> 'yes'
AND optionID IN (571, 573, 574, 575))

--5. Image Check ----------------------------------
--Check 1 of 2: the OPID has at least 1 existing image...
AND x.fileExists = 1
AND x.ignoreCheck = 0

--Check 2 of 2: ...but are any images missing for the existing OPID (e.g., the OPID's front image exists but the back image does not)?
AND NOT EXISTS
(SELECT TOP 1 1
FROM tblOPPO_fileExists e
WHERE e.fileExists = 0
AND e.OPID = x.OPID)