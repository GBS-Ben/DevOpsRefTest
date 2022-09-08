CREATE proc usp_getNBASales
@team varchar(255)

AS
declare @startDate varchar(255)
declare @endDate varchar(255)
set @startDate='06/01/2007'
set @endDate='05/01/2008'

insert into tblNBA_Sales (team, type, totalCartons, totalSales)
select @team, 'Custom', sum(productQuantity) as 'totalCartons', sum(productQuantity*productPrice) as 'TotalSales'  from tblOrders_Products where productName like '%custom%' and productName like '%basketball%' and deleteX<>'Yes' and orderID in
(select distinct orderID from tblOrders_Products where productName like '%'+@team+'%')
and orderID in (select distinct orderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed' and orderDate>convert(datetime, @startDate) and orderDate<convert(datetime, @endDate))
UNION
select @team, 'QuickStix', sum(productQuantity) as 'totalCartons', sum(productQuantity*productPrice) as 'TotalSales'  from tblOrders_Products where productName like '%quick%' and productName like '%basketball%' and deleteX<>'Yes' and orderID in
(select distinct orderID from tblOrders_Products where productName like  '%'+@team+'%')
and orderID in (select distinct orderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed' and orderDate>convert(datetime, @startDate) and orderDate<convert(datetime, @endDate))