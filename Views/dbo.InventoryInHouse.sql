




CREATE VIEW [dbo].[InventoryInHouse] --select * from [InventoryOrders]
AS
with cteINV as (select skupattern,sum(quantity-threshold) as quantity,max(modifieddate) as modifieddate from nopcommerce_tblproducts_inventory where supplier= 'gbs' group by skupattern)
,cteProducts as (
		SELECT DISTINCT op.id as OPID,op.productCode,op.productName,ISNULL(oppo.textvalue,'')  as size
		FROM tblOrders_Products op 
		INNER JOIN tblOPIDProductionProcess opp on op.id = opp.OpID
		LEFT JOIN tblOrdersProducts_ProductOptions oppo on op.id = oppo.ordersProductsID and optionCaption = 'size' and oppo.deletex <> 'yes'
	)

	select op2.id as opid,a.productCode,a.size,isnull(InhouseQty,0) as InhouseQty,
				sum(case when completed_On >  modifieddate then NumOrdered else 0 end) as stockassigned  --marked stock recieved after in house qty updated
				,sum(case when a.workflowid is not null and  completed_On is null then NumOrdered else 0 end) as stockpending 
	from (

	select op.productCode, op.workflowid,oi.size,NumOrdered=op.productQuantity*b.numUnits,opp1.completed_on,i.modifieddate,i.quantity as 'InhouseQty'
	--select distinct o.orderstatus,op.productquantity
	FROM tblOrders_Products op
	INNER JOIN cteProducts oi on op.id = oi.opid

	INNER JOIN tblProducts b ON op.productID = b.productID
	INNER JOIN tblOrders o ON op.orderID = o.orderID
	LEFT JOIN (select opid,completed_on FROM tblOPIDProductionProcess opp INNER JOIN gbsController_vwWorkflowProcess wp on opp.wpid = wp.wpid and wp.intranetTab = 'stock received' and opp.isactive = 1) opp1 
		on op.id = opp1.opid 
	LEFT JOIN cteINV i on substring(STUFF(STUFF(op.productCode,9,1,CASE oi.Size 
																				WHEN 'XS' THEN 'T'
																                WHEN 'small' THEN 'S'
																                WHEN 'medium' THEN 'M'
																                WHEN 'large' THEN 'L'
																                WHEN 'XL' THEN 'X'
																                WHEN '2XL' THEN '2'
																                WHEN '3XL' THEN '3'
																                WHEN '4XL' THEN '4'
																                WHEN '5XL' THEN '5' 
																				WHEN '' THEN '0' END),3,2,'__'),1,10) = i.skupattern

	WHERE op.deleteX <> 'yes' 
	AND o.orderStatus NOT IN ('failed', 'cancelled','Delivered','In Transit','on mrk doc')--exclude certain statuses
	AND op.productCode like 'AP%'
--	and op.productcode like 'AP__J5-W_N%'
	) a
	inner join tblorders_products op2 on op2.productcode = a.productcode 

	inner join cteProducts p2 on op2.id = p2.opid and p2.size = a.size
	WHERE op2.deletex <> 'yes'
	   AND left(op2.productCode,2) = 'AP'

	group by op2.id,a.productcode,a.size,isnull(InhouseQty,0)