
CREATE    proc  usp_ProductReport_Generic_byFixedDates
--THIS PROC PULLS DATA FOR PRODUCT_INVENTORY REPORT FOR NOTEPAD MAGS
--example:  exec usp_ProductReport_Generic_byFixedDates 'Last 7', 'Baseball'
--example:  exec usp_ProductReport_Generic_byFixedDates 'Yesterday', 'Baseball'
@interval varchar(255),
@productName varchar(255) --accepts: 'Last 7', 'Last 30', 'Last 60', 'Last 90', 'Last 120', 'Last 5 Months', 'Last Year'
as

declare 
@startDate datetime,
@endDate datetime


set @endDate='01/01/2999'


--YESTERDAY
if @interval='Yesterday'
begin
set @startdate=(select dbo.kk_fn_UTIL_DateRound(getdate(), -1))
set @enddate=(select dbo.kk_fn_UTIL_DateRound(getdate(), 0))
end

--LAST 7
if @interval='Last 7'
begin
set @startDate=dateadd(dd,-8,getdate())
end

--LAST 30
if @interval='Last 30'
begin
set @startDate=dateadd(dd,-31,getdate())
end

--LAST 60
if @interval='Last 60'
begin
set @startDate=dateadd(dd,-61,getdate())
end

--LAST 90
if @interval='Last 90'
begin
set @startDate=dateadd(dd,-91,getdate())
end

--LAST 120
if @interval='Last 120'
begin
set @startDate=dateadd(dd,-121,getdate())
end

--LAST 6 Months
if @interval='LAST 6 Months'
begin
set @startDate=dateadd(dd,-183,getdate())
end

--LAST Year
if @interval='Last Year'
begin
set @startDate=dateadd(dd,-366,getdate())
end

if @endDate='01/01/2999'
begin
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
and a.orderDate<getdate()
group by c.ProductName, c.stock_Level, c.productIndex
order by c.productName
end

if @endDate<>'01/01/2999'
begin
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
and a.orderDate<@endDate
group by c.ProductName, c.stock_Level, c.productIndex
order by c.productName
end