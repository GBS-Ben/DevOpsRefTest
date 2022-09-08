﻿
CREATE view v_products_ytd
--year to date
as
select 
a.orderdate, a.orderNo, 
b.productID, b.productName, b.productCode, b.productIndex, b.productPrice, b.productQuantity
,c.productName as 'primaryProduct'
from tblOrders a join tblOrders_Products b 
on a.orderID=b.orderID
join tblProducts c
on b.productIndex=c.productIndex
where b.productIndex is not null
and datepart(yy,orderdate)=datepart(yy,getdate())
and a.orderStatus<>'Cancelled' and a.orderStatus<>'Failed'