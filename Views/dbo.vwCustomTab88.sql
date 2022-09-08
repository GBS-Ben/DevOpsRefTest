






CREATE VIEW [dbo].[vwCustomTab88]
AS
	SELECT DISTINCT o.orderID,op.ID,
	CASE
		--Awards
		WHEN op.productCode LIKE 'AW%' THEN 'New-Awards' 
		--Signs
		WHEN op.productCode LIKE 'SN%' THEN 'New-Signs'
		--Apparel
		WHEN cd.digitized = 1 AND op.productCode LIKE 'AP%'AND cd.orderno NOT IN (SELECT orderno FROM vwCustomApparelOrders WHERE digitized = 0) THEN 'New-Apparel'
		WHEN cd.digitized = 1 AND op.productCode LIKE 'AP%'AND cd.orderno IN (SELECT orderno FROM vwCustomApparelOrders WHERE digitized = 0) THEN 'New-Apparel-Digitize'
		WHEN cd.digitized = 0 AND op.productCode LIKE 'AP%' THEN 'New-Apparel-Digitize'
		--Business Cards Lux
		WHEN op.productCode LIKE 'BP%' 
			AND EXISTS
				(SELECT TOP 1 1
				FROM tblOrdersProducts_productOptions oppx
				WHERE oppx.deleteX <> 'yes'
					AND (oppx.optionID IN (573, 574, 575)
					OR (oppx.optionCaption='Paper Stock' and (oppx.textValue like '%32%pt%' or oppx.textValue like '%52%pt%')))
					AND op.ID = oppx.ordersProductsID) THEN 'New-BC-Lux'
		--Magnetic Business Cards
		WHEN op.productCode LIKE 'BM%' THEN 'New-BC-MAG'
		--Masks
		WHEN op.productCode LIKE 'MK%' THEN 'New-Masks'
		--Pens
		WHEN op.productCode LIKE 'PN%' THEN 'New-Pens'
		--Nameplates
		WHEN op.productCode LIKE 'PL%' THEN 'New-Nameplates'
		--Envelopes
		WHEN ((SUBSTRING(op.productCode, 1, 2) = 'EV' OR SUBSTRING(op.productCode, 3, 2) = 'EV') AND op.productName LIKE '%envelope%' 
			 OR SUBSTRING(op.productCode, 1, 2) = 'LH') THEN 'New-Envelopes'
		--Mailings
		WHEN (SUBSTRING(op.productCode, 1, 2) = 'MS' OR SUBSTRING(op.productCode, 3, 2) = 'PM' OR SUBSTRING(op.productCode,1,4) = 'GNST')  THEN 'New-Mailings'
		--NotePads
		WHEN SUBSTRING(op.productCode,1,4) = 'GNNC' THEN 'New-NotePads'
		--Inserts
		WHEN (SUBSTRING(op.productCode, 3, 2) = 'IN' AND op.productName LIKE '%insert%') THEN 'New-Inserts'
		--Postcards
		WHEN (SUBSTRING(op.productCode, 1, 2) = 'PC')  THEN 'New-Postcards'
		--Presentation Folders
		WHEN (SUBSTRING(op.productCode, 1, 2) = 'CF') THEN 'New-Folders'
		--Custom_Art
		WHEN EXISTS
			(SELECT TOP 1 1
			FROM tblOrders o
			INNER JOIN tblOrders_Products opp
			ON o.orderID = opp.orderID
			INNER JOIN tblOrdersProducts_productOptions oppx ON oppx.ordersproductsID = opp.id
			AND ((oppx.optionCaption IN ('Change Fee', 'Design Fee') AND textValue = 'Yes')
				OR oppx.optionCaption = 'Previous Order Number')
			AND op.id = oppx.ordersProductsID) THEN 'New-Custom-Art'
		--Shaped_Badges
		WHEN (op.productCode LIKE 'NB__S%'   AND op.productCode NOT LIKE 'NB___U%') THEN 'New-Shaped-Badges'
		--Logo_Setup
		WHEN op.productCode = 'MC00SU-002' THEN 'New-Logo-Setup'
		--Vouchers
		WHEN op.productCode = 'PITM02' THEN 'New-Vouchers'
		--FA
		WHEN (op.fastTrak_status = 'In House'
			AND	(op.productcode LIKE '__FA%' OR op.productCode LIKE 'FA%')
			AND NOT EXISTS (SELECT top 1 1 
				FROM tblOrdersProducts_ProductOptions oppo WHERE oppo.ordersProductsID = op.Id
				AND DeleteX <> 'yes'
				AND optionID IN (641,374,373,21, 586, 702))) THEN 'New-ULYA'
		--_J
		WHEN op.fastTrak_status = 'In House'
			AND (SELECT TOP 1 RIGHT(oppo.textValue,2) 
				FROM tblOrdersProducts_productOptions oppo 
				WHERE oppo.ordersProductsID = op.ID 
					AND oppo.optionCaption = 'Default Layout' 
					AND deleteX <>'yes') = '_J'
			AND NOT EXISTS (SELECT top 1 1 
				FROM tblOrdersProducts_ProductOptions oppo WHERE oppo.ordersProductsID = op.Id
				AND DeleteX <> 'yes'
				AND optionID IN (641,374,373,21, 586, 702)) THEN 'New-ULYA'
		--Everything_Else
		WHEN op.productCode NOT LIKE 'AP%' THEN 'New-Misc'
		END AS 'TabSelected'
	FROM tblOrders o
	INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
	LEFT JOIN vwCustomApparelOrders cd ON cd.orderID = o.orderID
	WHERE o.archived = 0
	AND o.orderAck = 0
	AND op.isPrinted = 0
	AND o.tabStatus NOT IN ('Failed', 'Exception')
	AND o.orderType = 'Custom' 
	AND o.orderStatus NOT IN ('MIGZ' , 'Failed', 'Cancelled', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment')
	AND op.deleteX <> 'yes' 
	AND op.processType = 'Custom'