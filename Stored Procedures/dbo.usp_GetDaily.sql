CREATE proc [dbo].[usp_GetDaily]
as

declare @date datetime
set @date=(select getdate())


 delete from tblSalesReports

--[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[ YESTERDAY'S TOTALS ]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
--total Sales Value
insert into tblSalesReports (UID, comment, totalSales)
select 801, convert(varchar(255),datepart(mm,getdate()))+'/'+convert(varchar(255),datepart(dd,getdate()))+'/'+convert(varchar(255),datepart(yy,getdate())), sum(orderTotal) from tblOrders
where datediff(dd,orderDate, getdate())=1
and orderStatus<>'failed' and orderStatus<>'cancelled'
-- Calendar - Pads
insert into tblSalesReports (UID, comment, totalSales)
select 802,  'Yesterday - Calendars - Pads', sum(productPrice*ProductQuantity) from tblOrders_Products
--select * from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%calendar%' and productName like '%pad%'
and deleteX<>'Yes'
-- Calendars - QuickStix
insert into tblSalesReports (UID, comment, totalSales)
select 803,  'Yesterday - Calendars - QuickStix', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%quick%' and productName like '%stix%' and productName like '%calendar%'
and deleteX<>'Yes'
-- Calendars - QuickCards
insert into tblSalesReports (UID, comment, totalSales)
select 804,  'Yesterday - Calendars - QuickCards', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%quick%' and productName like '%cards%'
and deleteX<>'Yes'
-- Calendars - Custom Fulls
insert into tblSalesReports (UID, comment, totalSales)
select 805,  'Yesterday - Calendars - Custom Fulls', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%calendar%' and productName like '%custom%'
and deleteX<>'Yes'
-- Calendars - Cal Envelope
insert into tblSalesReports (UID, comment, totalSales)
select 806,  'Yesterday - Calendars - Envelopes', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%calendar%' and productName like '%envelope%' and productName not like '%holiday%'
and deleteX<>'Yes'
-- Holiday Envelope
insert into tblSalesReports (UID, comment, totalSales)
select 807,  'Yesterday - Calendars - Holiday Envelopes', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%holiday%' and productName like '%envelope%'
and deleteX<>'Yes'
-- Inserts - Football
insert into tblSalesReports (UID, comment, totalSales)
select 808,  'Yesterday - Inserts - Football', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%insert%' and productname like '%football%'
and deleteX<>'Yes'
-- Inserts - Calendars
insert into tblSalesReports (UID, comment, totalSales)
select 809,  'Yesterday - Inserts - Calendar', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%insert%' and productname like '%calendar%'
and deleteX<>'Yes'
-- Sweepstake entries - Football
insert into tblSalesReports (UID, comment, totalSales)
select 810,  'Yesterday - Sweepstakes Entries - Football', count(distinct([ID])) from tblFreeStuffEntry
where  datediff(dd,insertDate, getdate())=1
and entryFormID='football'
-- Sweepstake entries - Calendar
insert into tblSalesReports (UID, comment, totalSales)
select 811,  'Yesterday - Sweepstakes Entries - Gas', count(distinct([ID])) from tblFreeStuffEntry
where  datediff(dd,insertDate, getdate())=1
and entryFormID='gas'

--[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[ YTD TOTALS ]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
--YTD Sales
insert into tblSalesReports (UID, comment, totalSales)
select 812,  'YTD Sales as of: '+convert(varchar(255),datepart(mm,getdate()))+'/'+convert(varchar(255),datepart(dd,getdate()))+'/'+convert(varchar(255),datepart(yy,getdate())), sum(orderTotal) from tblOrders
where datepart(yy,orderDate)=datepart(yy,getdate())
and orderStatus<>'failed' and orderStatus<>'cancelled'
-- 2009 Season - Calendar - Pads
insert into tblSalesReports (UID, comment, totalSales)
select 813,  '2009 Season - Calendars - Pads', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%calendar%' and productName like '%Pad%'
and deleteX<>'Yes'
-- 2009 Season - Calendars - QuickStix
insert into tblSalesReports (UID, comment, totalSales)
select 814,  '2009 Season - Calendars - QuickStix', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%quick%' and productName like '%stix%' and productName like '%calendar%'
and deleteX<>'Yes'
-- 2009 Season - Calendars - QuickCards
insert into tblSalesReports (UID, comment, totalSales)
select 815,  '2009 Season - Calendars - QuickCards', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%quick%' and productName like '%cards%'
and deleteX<>'Yes'
-- 2009 Season - Calendars - Custom Fulls
insert into tblSalesReports (UID, comment, totalSales)
select 816,  '2009 Season - Calendars - Custom Fulls', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%calendar%' and productName like '%custom%'
and deleteX<>'Yes'
-- 2009 Season - Calendars - Cal Envelope
insert into tblSalesReports (UID, comment, totalSales)
select 817,  '2009 Season - Calendars - Envelopes', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%calendar%' and productName like '%envelope%' and productName not like '%holiday%'
and deleteX<>'Yes'
-- 2009 Season - Holiday Envelope
insert into tblSalesReports (UID, comment, totalSales)
select 818,  '2009 Season - Calendars - Holiday Envelopes', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%holiday%' and productName like '%envelope%'
and deleteX<>'Yes'
-- 2009 Season - Inserts - Football
insert into tblSalesReports (UID, comment, totalSales)
select 819,  '2009 Season - Inserts - Football', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%insert%' and productname like '%football%'
and deleteX<>'Yes'
-- 2009 Season - Inserts - Calendars
insert into tblSalesReports (UID, comment, totalSales)
select 820,  '2009 Season - Inserts - Calendar', sum(productPrice*ProductQuantity) from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%insert%' and productname like '%calendar%'
and deleteX<>'Yes'
-- 2009 Season - Sweepstake entries - Football
insert into tblSalesReports (UID, comment, totalSales)
select 821,  '2009 Season - Sweepstakes Entries - Football', count(distinct([ID])) from tblFreeStuffEntry
where  datediff(dd,insertDate, getdate())>1 and datediff(dd,insertDate, getdate())<200
and entryFormID='football'
-- 2009 Season - Sweepstake entries - Calendar
insert into tblSalesReports (UID, comment, totalSales)
select 822,  '2009 Season - Sweepstakes Entries - Gas', count(distinct([ID])) from tblFreeStuffEntry
where  datediff(dd,insertDate, getdate())>1 and datediff(dd,insertDate, getdate())<200
and entryFormID='gas'

--[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[ SPORTS ]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
-- Yesterday - All Football Magnet Sales
insert into tblSalesReports (UID, comment, totalSales)
select 823,   'Yesterday - All Football Magnet Sales',  sum(productPrice*ProductQuantity)  from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%football%' and productname not like '%envelope%'
and deleteX<>'Yes'
-- Yesterday - All Basketball Magnet Sales
insert into tblSalesReports (UID, comment, totalSales)
select 824,   'Yesterday - All Basketball Magnet Sales',  sum(productPrice*ProductQuantity)  from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%basketball%' and productname not like '%envelope%'
and deleteX<>'Yes'
-- Yesterday - All Hockey Magnet Sales
insert into tblSalesReports (UID, comment, totalSales)
select 825,   'Yesterday - All Hockey Magnet Sales',  sum(productPrice*ProductQuantity)  from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())=1 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%hockey%' and productname not like '%envelope%'
and deleteX<>'Yes'

-- 2009 Season - All Football Magnet Sales
insert into tblSalesReports (UID, comment, totalSales)
select 826,   '2009 Season - All Football Magnet Sales',  sum(productPrice*ProductQuantity)  from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%football%' and productname not like '%envelope%'
and deleteX<>'Yes'
-- 2009 Season - All Basketball Magnet Sales
insert into tblSalesReports (UID, comment, totalSales)
select 827,   '2009 Season - All Basketball Magnet Sales',  sum(productPrice*ProductQuantity)  from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%basketball%' and productname not like '%envelope%'
and deleteX<>'Yes'
-- 2009 Season - All Hockey Magnet Sales
insert into tblSalesReports (UID, comment, totalSales)
select 828,   '2009 Season - All Hockey Magnet Sales',  sum(productPrice*ProductQuantity)  from tblOrders_Products
where orderID in
(select orderID from tblOrders where datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 and orderStatus<>'failed' and orderStatus<>'cancelled')
and productname like '%hockey%' and productname not like '%envelope%'
and deleteX<>'Yes'

--YTD SPORTS
DECLARE @sport varchar(255)
DECLARE @teamName varchar(255)
DECLARE @SEQ int
DECLARE @SEQTOP int

SET @SEQ=900

DECLARE c_SportPop CURSOR FOR 
SELECT DISTINCT sport, teamName  FROM tblSportTeams
OPEN c_SportPop
FETCH NEXT FROM c_SportPop 
INTO @sport, @teamName
WHILE @@FETCH_STATUS = 0
	BEGIN
	
	IF @SEQTOP is null
		BEGIN
		SET @SEQTOP=@SEQ
		END

	insert into tblSalesReports (UID, comment, totalSales)
	select @SEQTOP, 'Yesterday - '+@teamName+' - '+@sport+' Magnet Sales',  sum(a.productPrice*b.ProductQuantity)  
	from tblOrders_Products a join tblOrders_Products b
	on a.[ID]=b.[ID]-1
	where a.orderID in
		(select orderID from tblOrders where 
		datediff(dd,orderDate, getdate())=1 
		--datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 
		and orderStatus<>'failed' and orderStatus<>'cancelled')
	and b. productName like '%'+@teamName+'%'
	and a.productname like '%'+@sport+'%' and a.productName not like '%envelope%'
	and a.deleteX<>'Yes'
	and b.deleteX<>'Yes'

	SET @SEQTOP=@SEQTOP+1
		
	FETCH NEXT FROM c_SportPop 
	INTO @sport, @teamName
	END
CLOSE c_SportPop
DEALLOCATE c_SportPop

--YESTERDAY SPORTS
DECLARE c_SportPopYTD CURSOR FOR 
SELECT DISTINCT sport, teamName  FROM tblSportTeams
OPEN c_SportPopYTD
FETCH NEXT FROM c_SportPopYTD 
INTO @sport, @teamName
WHILE @@FETCH_STATUS = 0
	BEGIN
	
	IF @SEQTOP is null
		BEGIN
		SET @SEQTOP=@SEQ
		END

	insert into tblSalesReports (UID, comment, totalSales)
	select @SEQTOP, 'YTD - '+@teamName+' - '+@sport+' Magnet Sales',  sum(a.productPrice*b.ProductQuantity)  
	from tblOrders_Products a join tblOrders_Products b
	on a.[ID]=b.[ID]-1
	where a.orderID in
		(select orderID from tblOrders where 
		--datediff(dd,orderDate, getdate())=1 
		datediff(dd,orderDate, getdate())>0 and datediff(dd,orderDate, getdate())<200 
		and orderStatus<>'failed' and orderStatus<>'cancelled')
	and b. productName like '%'+@teamName+'%'
	and a.productname like '%'+@sport+'%' and a.productName not like '%envelope%'
	and a.deleteX<>'Yes'
	and b.deleteX<>'Yes'

	SET @SEQTOP=@SEQTOP+1
		
	FETCH NEXT FROM c_SportPopYTD 
	INTO @sport, @teamName
	END
CLOSE c_SportPopYTD
DEALLOCATE c_SportPopYTD

update tblSalesReports set totalSales=0 where totalSales is null