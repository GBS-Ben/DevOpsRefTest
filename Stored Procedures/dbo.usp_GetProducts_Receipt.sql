CREATE proc [dbo].[usp_GetProducts_Receipt] 
@orderID int
as

--declare @orderID int = 555689233

select o.orderID
, o.orderDate
, op.ID as opid
, op.productID
, op.productName
, op.productPrice
, case when (left(op.productCode,2) = 'BP' or LEFT(op.productCode, 4) = 'GNNC' OR LEFT(op.productCode, 4) = 'FANC') then op.productPrice / 100 else op.productPrice end as productDisplayPrice
, op.productquantity
, case when (left(op.productCode,2) = 'BP' or LEFT(op.productCode, 4) = 'GNNC' OR LEFT(op.productCode, 4) = 'FANC') then op.productQuantity * 100 else op.productquantity end as productDisplayQuantity
, op.processType
,case when op.processType = 'fasTrak' then 'FASTRAK'
	when op.processType = 'stock' then 'STOCK'
	when op.processType = 'Custom' then 'CUSTOM' end as processTypeDisplay

, p.productCode
, p.productCompany
, p.shortDescription
, p.dateAvailable
, p.productType
, p.displayOrderGroup 
from tblOrders o
LEFT JOIN tblOrders_Products op
	on o.orderId = op.orderId
LEFT JOIN tblProducts p
on op.productID = p.productID 

where o.orderID = @orderID 
--AND (tblOrders_Products.processType = 'fasTrak') 
AND op.deletex <> 'yes' 
--AND LEFT(tblOrders_Products.productCode,4)<>'NCEV' 

--display order (fastrak, stock, custom)
order by 
	case when op.processType = 'fasTrak' then 10
		when op.processType = 'stock' then 20
		when op.processType = 'Custom' then 30 end
	,p.displayOrderGroup