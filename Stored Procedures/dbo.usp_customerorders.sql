

CREATE   proc usp_customerorders
@customerid  varchar(255)
as
select
o.orderno as 'Order_Number',
convert(varchar(255),(datepart(mm,o.orderdate)))+'/'+ convert(varchar(255),(datepart(dd,o.orderdate)))+'/'+ 
convert(varchar(255),(datepart(yy,o.orderdate)))  as 'Order_Date',
o.taxamountintotal+o.shippingamount+o.ordertotal as 'Total_Amount',
status as 'Order_Status'
from tblorders o
where o.customerid=@customerid