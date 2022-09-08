CREATE proc [dbo].[usp_GetMonthlyBillingProducts]
@orderId int
as
-- 04/27/21		CKB, added any oppo with non-zero option price

select distinct op.id
,processType = case op.processType
	when 'fasTrak' then 'FASTRAK PRODUCTS'
	when 'Custom' then 'CUSTOM PRODUCTS'
	when 'Stock' then 'STOCK PRODUCTS'
	else ''
	end
,processsort = case op.processType
	when 'fasTrak' then 0
	when 'Custom' then 2
	else  1
	end
,processType
,op.productName
,op.productQuantity
,op.productPrice
,(op.productQuantity * op.productPrice) SubTotal
,oppo.optionCaption
,case when oppo.textValue <> '1' then oppo.textValue else 'True' end as textValue
,oppo.optionPrice
,case when oppo.optionPrice = 0 then 0 
	  when oppo.optionPrice > 0 and oppo.optionQty = 0 then 1 else oppo.optionQty end as optionQty
from dbo.tblOrders_Products op
left join dbo.tblOrdersProducts_ProductOptions oppo
	on op.id = oppo.ordersProductsID
		and oppo.deletex <> 'yes'
		AND oppo.optionID <> 363 
		and ((oppo.optionGroupCaption in ('Description')
			or oppo.optionCaption like 'Info%'
			or oppo.optionCaption like 'GBS%'
			or oppo.optionCaption like '10%'
			or oppo.optionCaption like 'Group%'
			or oppo.optionCaption like 'Agent%')
			or oppo.optionPrice <> 0.00)
		and oppo.optionId <> 252
where 1=1
	and op.orderID = @orderId
	and op.deletex <> 'yes'
	--and oppo.deletex <> 'yes'
	--AND oppo.optionID <> 363 
	--and (oppo.optionGroupCaption in ('Description')
	--		or oppo.optionCaption like 'Info%'
	--		or oppo.optionCaption like 'GBS%'
	--		or oppo.optionCaption like '10%'
	--		or oppo.optionCaption like 'Group%'
	--		or oppo.optionCaption is null)
order by --op.processType
case op.processType
	when 'fasTrak' then 0
	when 'Custom' then 2
	else  1
	end
,op.id
,oppo.optionPrice
,oppo.optionCaption
,case when oppo.textValue <> '1' then oppo.textValue else 'True' end