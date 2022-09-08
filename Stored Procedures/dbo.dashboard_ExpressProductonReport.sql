CREATE proc [dbo].[dashboard_ExpressProductonReport]
as
--04/27/21	CKB, Markful

select  
o.orderNo as OrderNumber
,o.orderStatus as OrderStatus
,op.id as OPID
,o.orderDate as OrderDate
,ExpressProductionDueDate = dbo.fnAddBusinessDays(o.orderDate, 5)
,op.fastTrak_status as OPIDStatus

from tblOrders o
inner join tblOrders_Products op
	on o.orderID = op.orderID
where 
	exists
	(
		select 1
		from dbo.tblOrdersProducts_ProductOptions oppo
		where --optionCaption like '%express%' 
		 (optionCaption = 'Express Production' AND (textValue LIKE 'Yes%' OR textValue LIKE 'Express%' OR ISNULL(textValue,'') = ''))	-- added textValue qualifier for iFrame conversion
			and oppo.ordersProductsID = op.ID
	)
	and o.orderStatus not in ('Failed','Cancelled')
	and op.deletex <> 'Yes'
	--and o.orderDate > getdate() - 180
	--and op.fastTrak_status <> 'Completed'
	and o.orderStatus not in ('Delivered','On HOM Dock','ON HOM Dock','On MRK Dock','In Transit','In Transit USPS')