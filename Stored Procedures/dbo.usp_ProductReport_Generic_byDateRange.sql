CREATE PROC  usp_ProductReport_Generic_byDateRange
--THIS PROC PULLS DATA FOR PRODUCT_INVENTORY REPORT FOR NOTEPAD MAGS
@startDate datetime,
@endDate datetime,
@productName varchar(255)
--all time
as
select 
--a.orderDate,
--a.orderNo, 
--b.productID, 
--b.productName, --display
c.productIndex as 'productIndex',
c.productName as 'productName',
sum (b.productPrice*b.productQuantity) as 'TotalSales', --display
sum (b.productQuantity) as 'TotalQuantitySold', --display
c.stock_Level as 'stockLevel'--display
from tblOrders a join tblOrders_Products b 
on a.orderID=b.orderID
join tblProducts c
on b.productName=c.productName
where 
c.productName like '%'+@productName+'%'
and b.deletex <>'Yes'
and a.orderStatus<>'Cancelled' and a.orderStatus<>'Failed'
and a.orderDate>convert(datetime,@startDate)
and a.orderDate<dateadd(day,1,(convert(datetime,@endDate)))
group by c.ProductName, c.stock_Level, c.productIndex
order by c.productName