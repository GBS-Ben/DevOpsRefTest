CREATE PROCEDURE [dbo].[usp_AMZImport]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     01/11/09
-- Purpose     This process is called as Step #1 from the SSIS_AMZ scheduled job.
--					It grabs all new AMZ orders from the AMZ API (developed by Ron)
--					and moves that data to the appropriate locations.
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/12/16		Clean and prep for AMZ integration with Intranet; jf.
-- 8/30/16		Made many changes to orderStatus operations and notes written; beginning at LINE 115, jf.
-- 9/21/16		Modified LInes 155-168; notes related; jf.
-- 9/29/16		Added tblCustomers_ShippingAddress import section for address validation; jf.
-- 7/21/17	    Line 138  added LEFT to the NOTES = On HOM Dock clause
--11/14/17		update tblcustomers_shippingAddress section with '-ND' strip, jf.
--02/26/18		fixed tracksource, transactionDate to deal w/ NULLS, jf.
--04/27/21		CKB, Markful
--05/27/21		added envelope color section at the bottom of the proc, jf.
-------------------------------------------------------------------------------
--
--INSERT NEW RECORDS FROM the AMZ temp import table
SET NOCOUNT ON;

BEGIN TRY

INSERT INTO tblAMZ_orderValid 
([order-id], [order-item-id], [purchase-date], [payments-date], [reporting-date], [promise-date], [days-past-promise], [buyer-email], [buyer-name], [buyer-phone-number], [sku], [product-name], 
[quantity-purchased], [quantity-shipped], [quantity-to-ship], [currency], [item-price], [item-tax], 
[shipping-price], [shipping-tax], [ship-service-level], [recipient-name], [ship-address-1], [ship-address-2], 
[ship-address-3], [ship-city], [ship-state], [ship-postal-code], [ship-country], [ship-phone-number], [tax-location-code], [tax-location-city], 
[tax-location-county], [tax-location-state], [per-unit-item-taxable-district], [per-unit-item-taxable-city], 
[per-unit-item-taxable-county], [per-unit-item-taxable-state], [per-unit-item-non-taxable-district], [per-unit-item-non-taxable-city], 
[per-unit-item-non-taxable-county], [per-unit-item-non-taxable-state], [per-unit-item-zero-rated-district], 
[per-unit-item-zero-rated-city], [per-unit-item-zero-rated-county], [per-unit-item-zero-rated-state], [per-unit-item-tax-collected-district], 
[per-unit-item-tax-collected-city], [per-unit-item-tax-collected-county], [per-unit-item-tax-collected-state], 
[per-unit-shipping-taxable-district], [per-unit-shipping-taxable-city], [per-unit-shipping-taxable-county], [per-unit-shipping-taxable-state], 
[per-unit-shipping-non-taxable-district], [per-unit-shipping-non-taxable-city], [per-unit-shipping-non-taxable-county], 
[per-unit-shipping-non-taxable-state], [per-unit-shipping-zero-rated-district], [per-unit-shipping-zero-rated-city], 
[per-unit-shipping-zero-rated-county], [per-unit-shipping-zero-rated-state], [per-unit-shipping-tax-collected-district], 
[per-unit-shipping-tax-collected-city], [per-unit-shipping-tax-collected-county], [per-unit-shipping-tax-collected-state], 
[item-promotion-discount], [item-promotion-id], [ship-promotion-discount], [ship-promotion-id], [delivery-start-date], 
[delivery-end-date], [delivery-time-zone], [delivery-Instructions], [sales-channel], 
PKID)

SELECT 
[order-id], [order-item-id], [purchase-date], [payments-date], [reporting-date], [promise-date], [days-past-promise], [buyer-email], [buyer-name], [buyer-phone-number], [sku], [product-name], 
[quantity-purchased], [quantity-shipped], [quantity-to-ship], [currency], [item-price], [item-tax], 
[shipping-price], [shipping-tax], [ship-service-level], [recipient-name], [ship-address-1], [ship-address-2], 
[ship-address-3], [ship-city], [ship-state], [ship-postal-code], [ship-country], [ship-phone-number], [tax-location-code], [tax-location-city], 
[tax-location-county], [tax-location-state], [per-unit-item-taxable-district], [per-unit-item-taxable-city], 
[per-unit-item-taxable-county], [per-unit-item-taxable-state], [per-unit-item-non-taxable-district], [per-unit-item-non-taxable-city], 
[per-unit-item-non-taxable-county], [per-unit-item-non-taxable-state], [per-unit-item-zero-rated-district], 
[per-unit-item-zero-rated-city], [per-unit-item-zero-rated-county], [per-unit-item-zero-rated-state], [per-unit-item-tax-collected-district], 
[per-unit-item-tax-collected-city], [per-unit-item-tax-collected-county], [per-unit-item-tax-collected-state], 
[per-unit-shipping-taxable-district], [per-unit-shipping-taxable-city], [per-unit-shipping-taxable-county], [per-unit-shipping-taxable-state], 
[per-unit-shipping-non-taxable-district], [per-unit-shipping-non-taxable-city], [per-unit-shipping-non-taxable-county], 
[per-unit-shipping-non-taxable-state], [per-unit-shipping-zero-rated-district], [per-unit-shipping-zero-rated-city], 
[per-unit-shipping-zero-rated-county], [per-unit-shipping-zero-rated-state], [per-unit-shipping-tax-collected-district], 
[per-unit-shipping-tax-collected-city], [per-unit-shipping-tax-collected-county], [per-unit-shipping-tax-collected-state], 
[item-promotion-discount], [item-promotion-id], [ship-promotion-discount], [ship-promotion-id], [delivery-start-date], 
[delivery-end-date], [delivery-time-zone], [delivery-Instructions], [sales-channel], 
[order-id] + 'X' + [order-item-id] AS 'PKID'
FROM tblAMZ_orderImporter
WHERE [order-ID] + 'X' + [order-item-ID] NOT IN
		(SELECT PKID 
		FROM tblAMZ_orderValid)
AND [order-id] <> 'order-id'
ORDER BY [order-id] ASC

--Quick Clean Check
DELETE FROM tblAMZ_orderValid 
WHERE [order-id] = 'order-id'

DELETE FROM tblAMZ_orderShip 
WHERE [order-id] = 'order-id'

--INSERT NEW SHIP RECORDS FROM the previous table (tblAMZ_orderValid)
INSERT INTO tblAMZ_orderShip 
([order-id], orderDate, [buyer-email], [buyer-name], [buyer-phone-number], 
[recipient-name], [ship-address-1], [ship-address-2], [ship-address-3], [ship-city], [ship-state], [ship-postal-code], [ship-country], [ship-phone-number])

SELECT DISTINCT [order-id], 
SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) AS 'orderDate', 
[buyer-email], [buyer-name], [buyer-phone-number], 
[recipient-name], [ship-address-1], [ship-address-2], [ship-address-3], [ship-city], [ship-state], [ship-postal-code], [ship-country], [ship-phone-number]
FROM tblAMZ_orderValid
WHERE [order-id] NOT IN
		(SELECT [order-id] 
		FROM tblAMZ_orderShip)
ORDER BY [order-id] ASC

--Create orderNo
UPDATE tblAMZ_orderShip
SET orderNo = 'WEB' + CONVERT(VARCHAR(255), orderNo_ID)
WHERE orderNo IS NULL
AND orderNo_ID IS NOT NULL

--Propagate orderNo
UPDATE tblAMZ_orderValid
SET orderNo = b.orderNo, 
orderStatus = 'Ready to Print'
FROM tblAMZ_orderValid a
INNER JOIN tblAMZ_orderShip b ON a.[order-id] = b.[order-id]
WHERE a.orderNo IS NULL
AND b.orderNo IS NOT NULL
AND a.[order-id] IS NOT NULL
AND b.[order-id] IS NOT NULL

--UPDATE orderStatus
UPDATE tblAMZ_orderShip
SET orderStatus = 'In House'
WHERE orderStatus IS NULL

--// BEGIN: orderStatus and notes updates. --/////////////////////////////////////////////////////////////////////////////

--// ON HOM Dock
--// Update all orders that have been scanned, and therefore in tblJobTrack, as "ON HOM Dock'.
UPDATE tblAMZ_orderShip
SET orderStatus ='ON MRK Dock',
docked_on = GETDATE()
WHERE orderStatus <> 'Shipped'
AND orderStatus <> 'Delivered'
AND orderNo IN 
		(SELECT jobNumber 
		FROM tblJobTrack 
		WHERE SUBSTRING(jobNumber, 1, 3) = 'WEB')

--// Now write the ON HOM DOCK note:
INSERT INTO tbl_Notes (jobnumber, notes, notedate, author, notesType)
SELECT jobNumber, 'ON MRK Dock', 
CASE
	WHEN transactionDate IS NULL THEN GETDATE()
	ELSE transactionDate
END AS 'transactionDate', 
CASE
	WHEN trackSource IS NULL THEN 'UPS WorldShip'
	WHEN trackSource = '' THEN 'UPS WorldShip'
	ELSE trackSource
END AS 'trackSource', 
'order' 
FROM tblJobTrack
WHERE SUBSTRING(jobNumber, 1, 3) = 'WEB'
AND jobNumber NOT IN
	(SELECT jobNumber 
	FROM tbl_Notes 
	WHERE LEFT(CONVERT(VARCHAR(255), notes),11) IN ('ON HOM Dock','ON MRK Dock')
	AND notes IS NOT NULL)
AND jobNumber IN
	(SELECT orderNo 
	FROM tblAMZ_orderShip 
	WHERE orderStatus IN ('ON HOM Dock','ON MRK Dock'))

--// SHIPPED
--// Update the day's ON HOM Docks to shipped at night; operates after 8pm, weekdays.
UPDATE tblAMZ_orderShip
SET orderStatus = 'Shipped',
shipped_on = GETDATE()
WHERE orderStatus IN ('ON HOM Dock','ON MRK Dock')
AND DATEDIFF(DD, docked_on, GETDATE()) < 4
AND docked_on IS NOT NULL
AND DATEPART (HH, GETDATE()) >= 20
AND DATENAME(DW, GETDATE()) <> 'Saturday' 
AND DATENAME(DW, GETDATE()) <> 'Sunday'

--// Now write the SHIPPED note:
INSERT INTO tbl_Notes (jobnumber, notes, notedate, author, notesType)
SELECT orderNo, 'Shipped', GETDATE(), 'SQL', 'order' 
FROM tblAMZ_orderShip
WHERE orderStatus = 'Shipped'
AND DATEDIFF(DD, shipped_on, GETDATE()) < 2
AND shipped_on IS NOT NULL
AND orderNo NOT IN
	(SELECT jobNumber 
	FROM tbl_Notes 
	WHERE 
	jobNumber LIKE 'WEB%'
	AND (CONVERT(VARCHAR(255), notes) = 'Shipped' 
		 OR CONVERT(VARCHAR(255), notes) = 'Delivered') )
AND DATENAME(DW, GETDATE()) <> 'Saturday' 
AND DATENAME(DW, GETDATE()) <> 'Sunday'

--// DELIVERED
----// Update delivered after set period of time; operates after 8pm, Mon-Sat.
--UPDATE tblAMZ_orderShip
--SET orderStatus = 'Delivered',
--delivered_on = GETDATE()
--WHERE orderStatus = 'Shipped'
--AND DATEDIFF(DD, shipped_on, GETDATE()) >= 6
--AND shipped_on IS NOT NULL
--AND DATEPART (HH, GETDATE()) >= 20
--AND DATENAME(DW, GETDATE()) <> 'Sunday'

----// Now write the DELIVERED note:
--INSERT INTO tbl_Notes (jobnumber, notes, notedate, author, notesType)
--SELECT orderNo, 'Delivered', GETDATE(), 'SQL', 'order' 
--FROM tblAMZ_orderShip
--WHERE orderStatus = 'Delivered'
--AND orderNo NOT IN
--	(SELECT jobNumber 
--	FROM tbl_Notes 
--	WHERE CONVERT(VARCHAR(255), notes) = 'Delivered' 
--	AND notes IS NOT NULL)
--AND DATEDIFF(DD, shipped_on, GETDATE()) >= 6
--AND DATENAME(DW, GETDATE()) <> 'Sunday'

--// Remove any outliers from "SHIPPED" to "DELIVERED" (this should eventually fix itself; more for the next 20 days; 8/30/16; jf)
UPDATE tblAMZ_orderShip
SET orderStatus = 'Delivered',
delivered_on = GETDATE()
WHERE orderStatus = 'Shipped'
AND DATEDIFF(DD, orderDate, GETDATE()) > 45

--// END: orderStatus and notes updates. --/////////////////////////////////////////////////////////////////////////////

UPDATE tblAMZ_orderShip SET [ship-state] = REPLACE([ship-state], '.', '')
UPDATE tblAMZ_orderShip SET [ship-state] = 'AL' WHERE [ship-state] = 'Alabama'
UPDATE tblAMZ_orderShip SET [ship-state] = 'AK' WHERE [ship-state] = 'Alaska'
UPDATE tblAMZ_orderShip SET [ship-state] = 'AZ' WHERE [ship-state] = 'Arizona'
UPDATE tblAMZ_orderShip SET [ship-state] = 'AR' WHERE [ship-state] = 'Arkansas'
UPDATE tblAMZ_orderShip SET [ship-state] = 'CA' WHERE [ship-state] = 'California'
UPDATE tblAMZ_orderShip SET [ship-state] = 'CO' WHERE [ship-state] = 'Colorado'
UPDATE tblAMZ_orderShip SET [ship-state] = 'CT' WHERE [ship-state] = 'Connecticut'
UPDATE tblAMZ_orderShip SET [ship-state] = 'DE' WHERE [ship-state] = 'Delaware'
UPDATE tblAMZ_orderShip SET [ship-state] = 'DC' WHERE [ship-state] = 'District of Columbia'
UPDATE tblAMZ_orderShip SET [ship-state] = 'FL' WHERE [ship-state] = 'Florida'
UPDATE tblAMZ_orderShip SET [ship-state] = 'GA' WHERE [ship-state] = 'Georgia'
UPDATE tblAMZ_orderShip SET [ship-state] = 'HI' WHERE [ship-state] = 'Hawaii'
UPDATE tblAMZ_orderShip SET [ship-state] = 'ID' WHERE [ship-state] = 'Idaho'
UPDATE tblAMZ_orderShip SET [ship-state] = 'IL' WHERE [ship-state] = 'Illinois'
UPDATE tblAMZ_orderShip SET [ship-state] = 'IN' WHERE [ship-state] = 'Indiana'
UPDATE tblAMZ_orderShip SET [ship-state] = 'IA' WHERE [ship-state] = 'Iowa'
UPDATE tblAMZ_orderShip SET [ship-state] = 'KS' WHERE [ship-state] = 'Kansas'
UPDATE tblAMZ_orderShip SET [ship-state] = 'KY' WHERE [ship-state] = 'Kentucky'
UPDATE tblAMZ_orderShip SET [ship-state] = 'LA' WHERE [ship-state] = 'Louisiana'
UPDATE tblAMZ_orderShip SET [ship-state] = 'ME' WHERE [ship-state] = 'Maine'
UPDATE tblAMZ_orderShip SET [ship-state] = 'MD' WHERE [ship-state] = 'Maryland'
UPDATE tblAMZ_orderShip SET [ship-state] = 'MA' WHERE [ship-state] = 'Massachusetts'
UPDATE tblAMZ_orderShip SET [ship-state] = 'MI' WHERE [ship-state] = 'Michigan'
UPDATE tblAMZ_orderShip SET [ship-state] = 'MN' WHERE [ship-state] = 'Minnesota'
UPDATE tblAMZ_orderShip SET [ship-state] = 'MS' WHERE [ship-state] = 'Mississippi'
UPDATE tblAMZ_orderShip SET [ship-state] = 'MO' WHERE [ship-state] = 'Missouri'
UPDATE tblAMZ_orderShip SET [ship-state] = 'MT' WHERE [ship-state] = 'Montana'
UPDATE tblAMZ_orderShip SET [ship-state] = 'NE' WHERE [ship-state] = 'Nebraska'
UPDATE tblAMZ_orderShip SET [ship-state] = 'NV' WHERE [ship-state] = 'Nevada'
UPDATE tblAMZ_orderShip SET [ship-state] = 'NH' WHERE [ship-state] = 'New Hampshire'
UPDATE tblAMZ_orderShip SET [ship-state] = 'NJ' WHERE [ship-state] = 'New Jersey'
UPDATE tblAMZ_orderShip SET [ship-state] = 'NM' WHERE [ship-state] = 'New Mexico'
UPDATE tblAMZ_orderShip SET [ship-state] = 'NY' WHERE [ship-state] = 'New York'
UPDATE tblAMZ_orderShip SET [ship-state] = 'NC' WHERE [ship-state] = 'North Carolina'
UPDATE tblAMZ_orderShip SET [ship-state] = 'ND' WHERE [ship-state] = 'North Dakota'
UPDATE tblAMZ_orderShip SET [ship-state] = 'OH' WHERE [ship-state] = 'Ohio'
UPDATE tblAMZ_orderShip SET [ship-state] = 'OK' WHERE [ship-state] = 'Oklahoma'
UPDATE tblAMZ_orderShip SET [ship-state] = 'OR' WHERE [ship-state] = 'Oregon'
UPDATE tblAMZ_orderShip SET [ship-state] = 'PA' WHERE [ship-state] = 'Pennsylvania'
UPDATE tblAMZ_orderShip SET [ship-state] = 'RI' WHERE [ship-state] = 'Rhode Island'
UPDATE tblAMZ_orderShip SET [ship-state] = 'SC' WHERE [ship-state] = 'South Carolina'
UPDATE tblAMZ_orderShip SET [ship-state] = 'SD' WHERE [ship-state] = 'South Dakota'
UPDATE tblAMZ_orderShip SET [ship-state] = 'TN' WHERE [ship-state] = 'Tennessee'
UPDATE tblAMZ_orderShip SET [ship-state] = 'TX' WHERE [ship-state] = 'Texas'
UPDATE tblAMZ_orderShip SET [ship-state] = 'UT' WHERE [ship-state] = 'Utah'
UPDATE tblAMZ_orderShip SET [ship-state] = 'VT' WHERE [ship-state] = 'Vermont'
UPDATE tblAMZ_orderShip SET [ship-state] = 'VA' WHERE [ship-state] = 'Virginia'
UPDATE tblAMZ_orderShip SET [ship-state] = 'WA' WHERE [ship-state] = 'Washington'
UPDATE tblAMZ_orderShip SET [ship-state] = 'WV' WHERE [ship-state] = 'West Virginia'
UPDATE tblAMZ_orderShip SET [ship-state] = 'WI' WHERE [ship-state] = 'Wisconsin'
UPDATE tblAMZ_orderShip SET [ship-state] = 'WY' WHERE [ship-state] = 'Wyoming'
UPDATE tblAMZ_orderShip SET [ship-state] = 'VI' WHERE [ship-state] = 'Virgin Islands'
UPDATE tblAMZ_orderShip SET [ship-state] = 'GU' WHERE [ship-state] = 'Guam'

--//this section of code modifies the date value.
UPDATE tblAMZ_orderValid
SET [purchase-date] = 
CASE SUBSTRING([purchase-date], 12, 2)
	WHEN '00' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 12:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '01' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 1:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '02' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 2:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '03' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 3:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '04' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 4:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '05' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 5:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '06' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 6:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '07' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 7:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '08' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 8:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '09' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 9:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '10' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 10:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '11' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 11:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' AM'
	WHEN '12' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 12:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '13' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 1:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '14' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 2:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '15' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 3:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '16' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 4:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '17' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 5:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '18' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 6:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '19' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 7:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '20' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 8:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '21' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 9:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '22' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 10:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	WHEN '23' THEN SUBSTRING([purchase-date], 6, 2) + '/' + SUBSTRING([purchase-date], 9, 2) + '/' + SUBSTRING([purchase-date], 1, 4) + ' 11:' + SUBSTRING([purchase-date], 15, 2) + ':' + SUBSTRING([purchase-date], 18, 2) + ' PM'
	ELSE [purchase-date]
END
WHERE [purchase-date] IS NOT NULL
AND LEN([purchase-date]) = 25

--CLEAN
DELETE FROM tblAMZ_orderShip 
WHERE LEN(orderDate) <> 10

--Import addresses into tblCustomers_ShippingAddress for address validation via Endicia
INSERT INTO tblCustomers_ShippingAddress (CustomerID, Shipping_Company, Shipping_FirstName, Shipping_Surname, 
Shipping_Street, Shipping_Street2, Shipping_Suburb, Shipping_State, Shipping_PostCode, Shipping_Country, 
Shipping_Phone, Shipping_FullName, Primary_Address, orderNo, address_Type)

SELECT 555555555, [ship-address-3] AS 'Shipping_Company', 
[recipient-name], '',
[ship-address-1], [ship-address-2], [ship-city], [ship-state], REPLACE([ship-postal-code], '-ND', ''),
CASE [ship-country]
	WHEN 'US' THEN 'United States'
	ELSE [ship-country]
END,
LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([ship-phone-number], 'z', ''), 'y', ''), 'x', ''), 'w', ''), 'v', ''), 'u', ''), 't', ''), 's', ''), 'r', ''), 'q', ''), 'p', ''), 'o', ''), 'n', ''), 'm', ''), 'l', ''), 'k', ''), 'j', ''), 'i', ''), 'h', ''), 'g', ''), 'f', ''), 'e', ''), 'd', ''), 'c', ''), 'b', ''), 'a', ''), '#', ''), '_', ''), ',', ''), '.', ''), '/', ''), ')', ''), '(', ''), ' ', ''), '-', ''), 10) AS 'Shipping_Phone',
[recipient-name] AS 'Shipping_FullName', 1, orderNo, 0
FROM tblAMZ_orderShip AS AMZ
WHERE 
DATEDIFF(DD, CONVERT(DATETIME, orderDate), GETDATE()) <= 15
AND NOT EXISTS 
	(SELECT 1
	FROM tblCustomers_ShippingAddress AS CSA 
	WHERE AMZ.orderno = CSA.orderNo)	

--UPDATE tblAMZ_orderShip with validated addresses as they are validated in tblCustomers_ShippingAddress
UPDATE tblAMZ_orderShip
SET isValidated = b.isValidated,
	 rdi = b.rdi,
	 returnCode = b.returnCode,
	 addrExists = b.addrExists,
	 UPSRural = b.UPSRural,
	 [ship-address-1] = b.shipping_Street,
	 [ship-address-2] = b.shipping_Street2,
	 [ship-city] = b.shipping_Suburb,
	 [ship-state] = b.shipping_State,
	 [ship-postal-code] = b.shipping_PostCode,
	 [ship-country] = b.Shipping_Country
FROM tblAMZ_orderShip a
INNER JOIN tblCustomers_ShippingAddress b
	ON a.orderNo = b.orderNo
WHERE (a.isValidated = 0
		OR
		a.isValidated IS NULL)
AND b.isValidated = 1

-- determine weight per OPID
UPDATE tblAMZ_orderValid
SET weightOz = CONVERT(INT, [quantity-purchased]) * 13
WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
AND weightOz IS NULL

UPDATE tblAMZ_orderValid
SET weightOz = CONVERT(INT, [quantity-purchased]) * 30
WHERE [product-name] LIKE '%72%'
AND weightOz IS NULL


--update [product-name] to show associated envelope color so that fulfillment can do their job quicker
UPDATE v
SET [product-name] =  LEFT('(ENV COLOR: ' + ISNULL(n.Envelope_Color, '?') + ' - ' + ISNULL(n.ProductName, '?')  + ') ' + v.[product-name], 254)
FROM tblAMZ_ordervalid v
INNER JOIN AMZ_NCENVCOLOR n ON v.sku = n.sku
WHERE v.[product-name] NOT LIKE '(ENV COLOR:%'
AND n.envelope_color is not null
AND v.created_on > GETDATE()-15

UPDATE v SET [product-name] = LEFT('(ENV COLOR: Hot Pink) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Hot Pink Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Cobalt Blue) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Cobalt Blue Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Cobalt Blue) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%| Cobalt Blue |%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Green) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Green Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Green) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%| Green |%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Gray) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Gray Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Gray) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Grey Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Gray) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%| Gray |%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Aqua Blue Ocean) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Aqua Blue Ocean Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Tangerine Zest Orange) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Tangerine Zest Orange Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Red) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Red Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Off White Ivory) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Off White Ivory Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Lilac Purple) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Lilac Purple Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Kraft) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Kraft Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Kraft) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Kraft%Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Yellow) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Yellow Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: White) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%White Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Plum Purple) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Plum Purple Envelopes%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Plum Purple) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%| Plum Purple |%' AND v.created_on > GETDATE()-15
UPDATE v SET [product-name] = LEFT('(ENV COLOR: Key Lime Green) ' + v.[product-name], 254) FROM tblAMZ_ordervalid v WHERE v.[product-name] NOT LIKE '(ENV COLOR:%' AND v.[product-name] LIKE '%Key Lime Green Envelopes%' AND v.created_on > GETDATE()-15


END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH