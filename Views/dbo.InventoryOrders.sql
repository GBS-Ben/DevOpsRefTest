
CREATE VIEW [dbo].[InventoryOrders] --select * from [InventoryOrders]
AS
with cteUpdate as (select max(modifieddate) as modifieddate from nopcommerce_tblproducts_inventory where supplier= 'sanmar')

	select opid,productCode,textValue,case when completed_On >  modifieddate then NumOrdered 
					 when workflowid is null AND fasttrak_status <> 'complete' then NumOrdered else 0 end as neworders
				,case when workflowid is not null and  completed_On is null then NumOrdered else 0 end as pendingorders 
	from (
	select o.orderdate, o.orderNo, a.id as opid, a.productCode, a.workflowid, a.fasttrak_status,oppo.optionCaption, oppo.textValue, NumOrdered=a.productQuantity*b.numUnits,opp1.opid as prodopid,opp1.completed_on,u.modifieddate,o.orderstatus
	--select distinct o.orderstatus
	FROM tblOrders_Products a
	INNER JOIN tblProducts b ON a.productID = b.productID
	INNER JOIN tblOrders o ON a.orderID = o.orderID
	LEFT JOIN (select opid,completed_on FROM tblOPIDProductionProcess opp INNER JOIN gbsController_vwWorkflowProcess wp on opp.wpid = wp.wpid and wp.intranetTab = 'stock order' and opp.isactive = 1) opp1 
		on a.id = opp1.opid 
	LEFT JOIN dbo.tblOrdersProducts_ProductOptions oppo on oppo.ordersProductsID=a.id AND oppo.optionCaption='Size'
	CROSS APPLY (select modifieddate from cteUpdate) u
	WHERE a.deleteX <> 'yes' and oppo.deletex <>  'yes'
	AND o.orderStatus NOT IN ('failed', 'cancelled','Delivered','In Transit','on mrk doc')--exclude certain statuses
	AND a.productCode like 'AP%'
	) a
GO
