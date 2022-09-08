CREATE PROCEDURE [dbo].[Dashboard_ProductsMissingOPPOs]
AS
-------------------------------------------------------------------------------------
-- Author      Cherilyn
-- Created     02/24/21
-- Purpose     Retrieves products missing oppos for Brian
-------------------------------------------------------------------------------------
-- Modification History
--04/27/21	CKB, Markful
-------------------------------------------------------------------------------------

SELECT DISTINCT o.orderNo, o.orderDate, 
CONVERT(VARCHAR(50), DATEPART(MM, o.orderDate)) AS 'Month', 
DATEPART(DD, o.orderDate) AS 'Day',
DATEPART(YY, o.orderDate) AS 'Year',
op.ID AS 'OPID', op.productCode, case when left(op.productCode,2) = 'BP' then op.productQuantity * 100 else op.productQuantity end as 'Product Quantity'
FROM tblOrdersProducts_ProductOptions oppo 
INNER JOIN tblOrders_Products op on op.ID = oppo.ordersProductsId
inner join tblorders o on op.orderid  = o.orderid
WHERE op.ID not in (

SELECT op.id
FROM tblOrdersProducts_ProductOptions oppo 
INNER JOIN tblOrders_Products op on op.ID = oppo.ordersProductsId
inner join tblorders o on op.orderid  = o.orderid
where (op.productcode like 'bp%' and oppo.optionID in (640,674,650,571,572,573,574))
   or (op.productcode like 'nb%' and oppo.optionID in (651,646,630))
   or (op.productcode like 'SN__P%' and oppo.optionid in (704,616,613,565,576))
   or (op.productcode like 'SN__D%' and oppo.optionid in (648,616,613,565,576))
   or (op.productcode like 'SN__R%' and oppo.optionid in (685,616,613,565,576))
   or (op.productcode like 'NC%' and op.productcode not like 'ncev%' and left(o.orderNo,3) = 'NCC' and oppo.optionid in (615,669))
   or (op.productcode like 'NC%' and op.productcode  like 'ncev%'  and oppo.optionid in (649))
    or (op.productcode like 'GNNC%' and oppo.optionid in (765,775,755))
 and oppo.deletex <> 'yes'
 )
  and op.created_on >= '02/06/2021'
  and ( (op.productcode like 'bp%' )
   or (op.productcode like 'nb%' )
   or (op.productcode like 'SN__P%' )
   or (op.productcode like 'SN__D%' )
   or (op.productcode like 'SN__R%' )
   or (op.productcode like 'NC%' and op.productcode not like 'ncev%'  and left(o.orderNo,3) = 'NCC')
    or (op.productcode like 'NC%' and op.productcode  like 'ncev%' )
  or (op.productcode like 'GNNC%'  ))
AND o.orderstatus not in ('Failed', 'Cancelled','MIGZ', 'Delivered', 'In Transit', 'In Transit USPS','On HOM Dock','On MRK Dock')
AND o.displayPaymentStatus IN ('Good', 'Credit Due')
order by o.orderdate