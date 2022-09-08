










CREATE VIEW [dbo].[vwOPIDInventory]
AS

with cteProducts as (
		SELECT DISTINCT op.id as OPID,op.productCode,op.productName,ISNULL(oppo.textvalue,'')  as size
		FROM tblOrders_Products op 
		INNER JOIN tblOPIDProductionProcess opp on op.id = opp.OpID
		LEFT JOIN tblOrdersProducts_ProductOptions oppo on op.id = oppo.ordersProductsID and optionCaption = 'size' and oppo.deletex <> 'yes'
	)
	,cteCounts as (select skupattern,isnull(availableQuantity,0) as availablequantity,isnull(pendingQuantity,0) pendingQuantity from dbo.InventoryCounts)
	select distinct 
	p.opid
		,p.size
		,pii.Color
		,pii.GTIN
		,pii.catalogNo
		,pii.quantity as 'sanmarqty'
		,pii.skupattern
		,ic.availableQuantity
		,ic.pendingQuantity
	FROM cteProducts p
	LEFT JOIN nopCommerce_vwTblProducts_InventorytopSanMar pii on  pii.skupattern = substring(STUFF(STUFF(p.productCode,9,1,CASE p.Size 
																				WHEN 'XS' THEN 'T'
																                WHEN 'small' THEN 'S'
																                WHEN 'medium' THEN 'M'
																                WHEN 'large' THEN 'L'
																                WHEN 'XL' THEN 'X'
																                WHEN '2XL' THEN '2'
																                WHEN '3XL' THEN '3'
																                WHEN '4XL' THEN '4'
																                WHEN '5XL' THEN '5' 
																				WHEN '' THEN '0' END),3,2,'__'),1,10) 
	LEFT JOIN cteCounts ic on ic.skupattern = substring(STUFF(STUFF(p.productcode,9,1,CASE p.Size 
																				WHEN 'XS' THEN 'T'
																                WHEN 'small' THEN 'S'
																                WHEN 'medium' THEN 'M'
																                WHEN 'large' THEN 'L'
																                WHEN 'XL' THEN 'X'
																                WHEN '2XL' THEN '2'
																                WHEN '3XL' THEN '3'
																                WHEN '4XL' THEN '4'
																                WHEN '5XL' THEN '5' 
																				WHEN '' THEN '0' END),3,2,'__'),1,10)