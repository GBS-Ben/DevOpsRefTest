CREATE PROC [dbo].[usp_ShippingLabels]
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/05/15
-- Purpose     This SPROC refreshes data for A1 label / Endicia API
--					This is called by job "i_A1_usp_ShippingLabels" which runs every 75s.
-------------------------------------------------------------------------------
-- Modification History
-- 11/2/2016	Updated marketplace section to include mailpieceShape information.
-- 11/16/2016	Changed tblAMZ_orderShip.a1_mailRate to tblAMZ_orderShip.a1_mailPieceShape, jf.
-- 12/27/2016	added isValidated check to marketplace query, jf.
-- 03/22/2017	added USPS clause to USPS Marketplace code (AND a.a1_Carrier = 'USPS'), jf.
-- 03/22/2017	added UPS section to Marketplace, jf.
-- 03/28/2017	updated weight and desc in UPS section, jf.
-- 03/31/2017	updated weight calc for UPS labels, jf.
-- 04/04/2017	updated phone insert with REPLACE statement, jf.
-- 04/24/2020	Y2K Work CONVERT(INT, STUFF(orderNo, 1, PATINDEX('%[0-9]%', orderNo)-1,''))
-- 04/30/2020   Added weight calcs, jf.
-- 08/13/2020	JF, added YSPOL conditions towards the bottom of proc.
-- 12/29/2020	CKB, modified shiptophone logic to include maintenance_FixtblUPSLabl logic
-- 01/11/2021	CB, modified tblUPSLabel insert to limit the address1 to 50 characters, fixing the truncation error
-- 04/27/2021	CKB, Markful
-- 05/03/2021	JF, added YSGRD conditions towards the bottom of proc.
-- 05/12/2021	JF, added IN (0,1) to all bottom queries
-------------------------------------------------------------------------------
AS
SET NOCOUNT ON;

BEGIN TRY
--// HOM/NCC ////////////////////////////////////////////////////////////////////////////////////////
--now, insert all new records into tblShippingLabels, that is used by the Endicia API to gen labels.
INSERT INTO tblShippingLabels (mailClass, weightOz, mailpieceShape, referenceID, storeID, orderID)
SELECT 'Priority', 
CASE
	WHEN a.orderWeight IS NULL THEN 3
END AS 'orderWeight', 
'FlatRatePaddedEnvelope', a.orderNo, a.storeID, a.orderID
FROM tblOrders a
WHERE 
a.a1 = 1
AND a.orderNo NOT IN
	(SELECT referenceID
	FROM tblShippingLabels
	WHERE referenceID IS NOT NULL)

UPDATE tblShippingLabels
SET weightOz = 3
WHERE weightOz IS NULL
OR weightOz = 0

--// MARKETPLACE /////////////////////////////////////////////////////////////////////////////////////
-- Weight Conversion
UPDATE tblAMZ_orderValid
SET weightOz = CONVERT(INT, [quantity-purchased]) * 13
WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
AND weightOz IS NULL

UPDATE tblAMZ_orderValid
SET weightOz = CONVERT(INT, [quantity-purchased]) * 30
WHERE [product-name] LIKE '%72%'
AND weightOz IS NULL

-- USPS Label Prep
INSERT INTO tblShippingLabels (mailClass, weightOz, mailpieceShape, referenceID, storeID, orderID)
SELECT 
a.a1_mailClass, 
SUM(b.weightOz),
a.a1_mailPieceShape, 
a.orderNo, 4, b.[order-id]
FROM tblAMZ_orderShip a
JOIN tblAMZ_orderValid b
	ON a.orderNo = b.orderNo
WHERE 
a.a1 = 1
AND a.a1_Carrier = 'USPS'
AND a.isValidated IS NOT NULL
AND a.orderNo NOT IN
	(SELECT referenceID
	FROM tblShippingLabels
	WHERE referenceID IS NOT NULL)
AND a.orderStatus NOT IN ('Shipped', 'Delivered', 'Cancelled', 'On HOM Dock', 'On MRK Dock')
AND CONVERT(INT, STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'')) > 181509
GROUP BY a.a1_mailClass,
a.a1_mailPieceShape, 
a.orderNo, b.[order-id]

--UPS Label Prep
INSERT INTO tblUPSLabel (shipperName, shipperAttentionName, shipperStreet, shipperCity, 
shipperState, shipperPostalCode, shipperCountry, shipperPhone, shiptoFullName,  
shiptoCompany, shiptoStreet, shiptoStreet2, shiptoCity, shiptoState, shiptoPostalCode, shiptoCountry, 
shiptoPhone, orderNo, shipDescription, upsServiceCode, packageWeight, unitOfMeasure, packageTypeCode, 
labelGenerated, errorReceived, insertDate)
select shipperName
    , shipperAttentionName
    , shipperStreet
    , shipperCity
    , shipperState
    , shipperPostalCode
    , shipperCountry
    , shipperPhone
    , shiptoFullName
    , shiptoCompany
    , left(shiptoStreet,50) as shiptoStreet
    , shiptoStreet2
    , shiptoCity
    , shiptoState
    , shiptoPostalCode
    , shiptoCountry
	, case 
		when len(case 
					when left(shiptophone,1) = 1 then substring(shiptophone,2,10)
					else left(shiptophone,10) 
					end) < 10 then '0000000000' 
		else 
			case 
				when left(shiptophone,1) = 1 then substring(shiptophone,2,10)
				else left(shiptophone,10) 
			end
		end as 'shiptophone' 
    , orderNo
    , shipDescription
    , upsServiceCode
    , packageWeight
    , unitOfMeasure
    , packageTypeCode
    , labelGenerated
    , errorReceived
    , insertDate
	from (
		SELECT 
		  'Note Card Cafe' as 'shipperName'
		, 'Shipping Department' as 'shipperAttentionName'
		, '1912 John Towers Ave.' as 'shipperStreet'
		, 'El Cajon' as 'shipperCity'
		, 'CA' as 'shipperState'
		, '92020' as 'shipperPostalCode'
		, 'US' as 'shipperCountry'
		, '6192584087' as 'shipperPhone'
		, a.[recipient-name] as 'shiptoFullName'
		, a.[ship-address-3] AS 'shipToCompany'
		, a.[ship-address-1] as 'shiptoStreet'
		, a.[ship-address-2] as 'shiptoStreet2'
		, a.[ship-city] as 'shiptoCity'
		, a.[ship-state] as 'shiptoState'
		,a.[ship-postal-code] as 'shiptoPostalCode'
		, 'US' as 'shiptoCountry'
		--, LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a. [ship-phone-number], 'z', ''), 'y', ''), 'x', ''), 'w', ''), 'v', ''), 'u', ''), 't', ''), 's', ''), 'r', ''), 'q', ''), 'p', ''), 'o', ''), 'n', ''), 'm', ''), 'l', ''), 'k', ''), 'j', ''), 'i', ''), 'h', ''), 'g', ''), 'f', ''), 'e', ''), 'd', ''), 'c', ''), 'b', ''), 'a', ''), '#', ''), '_', ''), ',', ''), '.', ''), '/', ''), ')', ''), '(', ''), ' ', ''), '-', ''), 10) AS 'Shipping_Phone'
		,dbo.fnstripinvalidphonecharacters(a.[ship-phone-number]) as 'shiptoPhone'
		, a.orderNo
		, a.orderNo + '-' + a.[order-id] AS 'shipDescription'
		,CASE
				WHEN a.a1_mailClass = 'Ground' THEN '03'
			END AS 'upsServiceCode',
		CEILING(SUM(CONVERT(DECIMAL(10,2), ISNULL(b.weightOz, 0))/16)) as 'packageWeight',
		'LBS' as 'unitOfMeasure', 
		'02' AS 'packageTypeCode', 
		0 as 'labelGenerated', 
		0 as 'errorReceived', 
		GETDATE() as 'insertDate'
		FROM tblAMZ_orderShip a
		JOIN tblAMZ_orderValid b
				ON a.orderNo = b.orderNo
		WHERE
		a.a1 = 1
		AND a.a1_Carrier = 'UPS'
		AND a.isValidated IS NOT NULL
		AND a.orderNo NOT IN
				(SELECT orderNo
				FROM tblUPSLabel)
		--AND a.orderStatus NOT IN ('Shipped', 'Delivered', 'Cancelled', 'On HOM Dock')
		AND CONVERT(INT, STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'')) > 191694
		GROUP BY a.[recipient-name],
		a.[ship-address-3], a.[ship-address-1], a.[ship-address-2], a.[ship-city], a.[ship-state],
		a.[ship-postal-code], a.[ship-phone-number], a.orderNo, a.[order-id], a.a1_mailClass
) shipdata

--Update weight used for UPS label acquisition-------------------------------------------BEGIN

UPDATE a
SET packageWeight = 6  --select a.*
FROM tblUPSLabel a
INNER JOIN tblAMZ_orderShip s ON a.orderNo = s.orderNo
INNER JOIN tblAMZ_orderValid v ON s.orderNo = v.orderNo
WHERE s.a1_conditionID = 777
AND v.SKU LIKE 'YSHL%'
AND packageWeight IN (0,1)

UPDATE a
SET packageWeight = 10  --select a.*
FROM tblUPSLabel a
INNER JOIN tblAMZ_orderShip s ON a.orderNo = s.orderNo
INNER JOIN tblAMZ_orderValid v ON s.orderNo = v.orderNo
WHERE s.a1_conditionID = 777
AND v.SKU LIKE 'YSALH%'
AND packageWeight IN (0,1)

UPDATE a
SET packageWeight = 1  --select a.*
FROM tblUPSLabel a
INNER JOIN tblAMZ_orderShip s ON a.orderNo = s.orderNo
INNER JOIN tblAMZ_orderValid v ON s.orderNo = v.orderNo
WHERE s.a1_conditionID = 777
AND (v.SKU LIKE 'YSCVD%'
		OR v.SKU LIKE 'YSGRD%')
AND packageWeight = 0

UPDATE a
SET packageWeight = 1  --select a.*
FROM tblUPSLabel a
INNER JOIN tblAMZ_orderShip s ON a.orderNo = s.orderNo
INNER JOIN tblAMZ_orderValid v ON s.orderNo = v.orderNo
WHERE s.a1_conditionID = 777
AND v.SKU LIKE 'YSPOL%'
AND [product-name] LIKE '%single%'
AND packageWeight = 0

UPDATE a
SET packageWeight = 3  --select a.*
FROM tblUPSLabel a
INNER JOIN tblAMZ_orderShip s ON a.orderNo = s.orderNo
INNER JOIN tblAMZ_orderValid v ON s.orderNo = v.orderNo
WHERE s.a1_conditionID = 777
AND v.SKU LIKE 'YSPOL%'
AND ([product-name] LIKE '%3 pack%' 
	OR [product-name] LIKE '%3-pack%')
AND packageWeight IN (0,1)

UPDATE a
SET packageWeight = 4  --select a.*
FROM tblUPSLabel a
INNER JOIN tblAMZ_orderShip s ON a.orderNo = s.orderNo
INNER JOIN tblAMZ_orderValid v ON s.orderNo = v.orderNo
WHERE s.a1_conditionID = 777
AND (v.SKU LIKE 'YSPOL%'
	OR v.SKU LIKE 'YSGRD%')
AND ([product-name] LIKE '%4 pack%' 
	OR [product-name] LIKE '%4-pack%')
AND packageWeight IN (0,1)

UPDATE a
SET packageWeight = 8  --select a.*
FROM tblUPSLabel a
INNER JOIN tblAMZ_orderShip s ON a.orderNo = s.orderNo
INNER JOIN tblAMZ_orderValid v ON s.orderNo = v.orderNo
WHERE s.a1_conditionID = 777
AND (v.SKU LIKE 'YSPOL%'
	OR v.SKU LIKE 'YSGRD%')
AND ([product-name] LIKE '%8 pack%' 
	OR [product-name] LIKE '%8-pack%')
AND packageWeight IN (0,1)


--Update weight used for UPS label acquisition-------------------------------------------END

END TRY
BEGIN CATCH
	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH