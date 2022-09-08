CREATE proc [dbo].[usp_monthlyTotals]
as
delete from tblMonthlyTotals

insert into tblMonthlyTotals (orderDate,orderTotal,orderQuantity)
select 
convert(varchar(255),(datepart(mm,orderdate)))+'/'+convert(varchar(255),(datepart(dd,orderdate)))+'/'+convert(varchar(255),(datepart(yyyy,orderdate))) as 'OrderDate',
sum(ordertotal) as 'orderTotal',
'1' as 'orderQuantity'
--into tblMonthlyTotals
from tblOrders
where orderStatus<>'Failed'
and orderStatus<>'Cancelled'
and datediff(dd,orderdate,getdate())<31
group by orderDate,ordertotal
order by convert(datetime,orderdate) asc

select 
  CASE
      WHEN (Grouping(orderDate)=1) THEN '30 Day Totals'
      ELSE cast(orderDate as varchar(20))
  END AS orderDate, 

--orderDate,
sum(orderTotal) as 'orderTotal',
sum(convert(int,orderQuantity)) as 'orderQuantity'
from tblMonthlyTotals
group by orderdate
with rollup
order by convert(datetime,orderdate) asc