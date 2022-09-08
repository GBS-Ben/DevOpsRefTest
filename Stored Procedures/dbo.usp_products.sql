

--exec dbo.usp_products 'DT071340020398'

CREATE     proc usp_products
@orderno varchar(255)
as
select 
p.[id] as 'ID',
p.orderid as 'OrderID',
p.productID as 'Product_ID',
p.productname as 'Product_Name',
p.productprice as 'Product_Price',
p.productquantity as 'Quantity',
p.status as 'Fulfillment_Status'--,
--z.optioncaption as 'Option_Caption',
--z.optionprice as 'Option_Price',
--z.textvalue as 'Option_Text',
--k.optiondiscountapplies 'Option_Discount'
from tblorders_products p join tblorders o 
on p.orderid=o.orderid
--join tblordersproducts_productoptions z 
--on z.ordersproductsid=p.[id]
--join tblproduct_productoptions k 
--on k.productid =p.productid
--select * from tblorders_products where deletex is not null
where o.orderid in
(select orderid from tblorders where o.orderno like '%'+@orderno+'%')
and p.deletex is  null
--or p.deletex = '0'