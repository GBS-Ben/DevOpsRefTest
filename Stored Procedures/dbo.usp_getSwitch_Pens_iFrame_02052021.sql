CREATE PROCEDURE [dbo].[usp_getSwitch_Pens_iFrame_02052021] 
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     08/3/15
-- Purpose     Pulls pen data for switch flow.
-------------------------------------------------------------------------------
-- Modification History
--
--11/20/17		updated shipping address to point to tblcustomers_shippingaddress
--						rather than tblorders, to receive the USPS API data, jf.
--04/24/2020	BJS Y2K Work
--1012/2020		BJS Goldstar pens work
-------------------------------------------------------------------------------
TRUNCATE TABLE tblSwitch_Pens
INSERT INTO tblSwitch_Pens (POnumber, Quantity, customerName, 
shipping_Address, shipping_Address2, shipping_City, shipping_State, shipping_Zip, 
vProductCode, vProductName, vPenColor, vImprintColor, vInkColor, vPricePerPiece, 
calcPrice, subtotal, PDF, ordersProductsID)

SELECT CONVERT(INT, STUFF(a.orderNo, 1, PATINDEX('%[0-9]%', a.orderNo)-1,'')) AS 'POnumber', op.productQuantity AS 'Quantity',
REPLACE ((z.shipping_FirstName + ' ' + z.shipping_SurName), '  ', ' ') as 'customerName',
z.shipping_Street AS 'Address', z.shipping_Street2 AS 'Address2', 
z.shipping_Suburb AS 'City', z.shipping_State AS 'State', z.shipping_PostCode AS 'Zip',
	 v.vProductCode, v.vProductName, 
	 --v.vPenColor, v.vImprintColor,
	--v.vInkColor, 
	--v.vPricePerPiece,  
	--(v.vPricePerPiece * op.productQuantity) + 15 AS 'calcPrice',
	--(v.vPricePerPiece * op.productQuantity) AS 'subtotal',
	--REPLACE(oppo.textValue, '/InProduction/Pens/', '') AS 'PDF',
	(SELECT TOP  1 oppo.textValue
	FROM tblOrdersProducts_productOptions oppo 
	WHERE op.ID = oppo.ordersProductsID 
		AND oppo.OptionCaption = 'Pen - Barrel Color'
		AND oppo.deletex <> 'yes'
		) AS vPenColor, --Pen - Barrel Color
	ISNULL((SELECT TOP  1oppo.textValue
	FROM tblOrdersProducts_productOptions oppo 
	WHERE op.ID = oppo.ordersProductsID 
		AND oppo.OptionCaption = 'Imprint Color'
		AND oppo.deletex <> 'yes'
		),'White') AS vImprintColor, --Imprint Color  --when null then WHITE
	(SELECT TOP  1 REPLACE(oppo.textValue,'InkColor_','')
	FROM tblOrdersProducts_productOptions oppo 
	WHERE op.ID = oppo.ordersProductsID 
		AND oppo.OptionCaption = 'Ink Color'
		AND oppo.deletex <> 'yes'
		)
	 AS  vInkColor,     --Ink Color
	v.vPricePerPiece,  
	(v.vPricePerPiece * op.productQuantity) + 15 AS 'calcPrice',
	(v.vPricePerPiece * op.productQuantity) AS 'subtotal',
	(SELECT TOP  1 oppo.textValue
	FROM tblOrdersProducts_productOptions oppo 
	WHERE op.ID = oppo.ordersProductsID 
		AND oppo.OptionCaption = 'Intranet PDF'
		AND oppo.deletex <> 'yes'
		)  AS 'PDF',    --- Intranet PDF    
		op.Id	--SELECT * 
FROM tblOrders a
JOIN tblOrders_Products op
	ON a.orderID = op.orderID
JOIN tblVendor_PensMaster v
	ON op.productCode = v.productCode   
--JOIN tblOrdersProducts_productOptions oppo
--	ON op.ID = oppo.ordersProductsID
JOIN tblCustomers_ShippingAddress z
	ON a.orderNo = z.orderNo
WHERE
	a.orderStatus <> 'cancelled'
	AND a.orderStatus <> 'failed'
	AND a.orderStatus NOT LIKE '%waiting%'
	AND a.displayPaymentStatus = 'Good'
	AND op.deleteX <> 'yes'
	--AND oppo.deleteX <> 'yes'
	AND SUBSTRING(op.productCode, 1, 2) = 'PN'
	--AND SUBSTRING(oppo.textValue, 14, 6) = '/Pens/'
	--AND op.switch_create = 0
	AND v.[Name] = 'Goldstar'  
	AND DATEDIFF(mi,a.orderDate,GETDATE()) > 30 
	AND (
		--3.a
		op.fastTrak_status = 'In House'
		AND op.switch_create = 0 
		AND EXISTS
				(SELECT TOP 1 1
				FROM tblOrdersProducts_productOptions opp1
				WHERE deleteX <> 'yes'
				AND optionCaption = 'OPC'
				AND opp1.ordersProductsID = op.ID)
		--3.b
		OR op.fastTrak_status = 'Good to Go'
		--3.c
		OR op.fastTrak_resubmit = 1
		)
-- Image Check ----------------------------------
--multiple images can exist per opid (e.g., front and back) so we want to check against the whole table.
AND NOT EXISTS				
	(SELECT TOP 1 1
	FROM tblOPPO_fileExists e
	WHERE e.readyForSwitch = 0
	AND e.OPID = op.ID
	AND NOT EXISTS
		(SELECT TOP 1 1
		FROM tblOPPO_fileExists ee
		WHERE ee.readyForSwitch = 1
		AND e.OPID = ee.OPID))

	
/*
UPDATE tblSwitch_Pens
SET vInkColor = b.optionCaption
FROM tblSwitch_Pens a
JOIN tblOrdersProducts_productOptions b
	ON a.ordersProductsID = b.ordersProductsID
WHERE b.optionGroupCaption = 'Ink Option'
AND b.deleteX <> 'yes'

UPDATE tblSwitch_Pens
SET vImprintColor = oppo.optionCaption
FROM tblSwitch_Pens a
JOIN tblOrdersProducts_productOptions oppo
	ON a.ordersProductsID = oppo.ordersProductsID
WHERE oppo.optionGroupCaption = 'Imprint Color'
AND oppo.deleteX <> 'yes'
*/

UPDATE tblSwitch_Pens
SET shipType = b.shippingDesc
FROM tblSwitch_Pens a
JOIN tblOrders b
	ON a.POnumber =  STUFF(orderNo, 1, PATINDEX('%[0-9]%', orderNo)-1,'')
WHERE b.orderNo IS NOT NULL


--Update OPID status fields indicating successful submission to switch
UPDATE op
SET switch_create = 1,
	fastTrak_resubmit = 0,	
	fastTrak_status = 'In Production', --will remove this once logging is in place in Switch
	fastTrak_status_lastModified = GETDATE()	--will remove this once logging is in place in Switch
FROM tblOrders_Products op
INNER JOIN tblSwitch_Pens q ON op.ID = q.ordersProductsID

SELECT * 
FROM tblSwitch_Pens 
ORDER BY PKID