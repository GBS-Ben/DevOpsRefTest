--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//

CREATE PROC [dbo].[usp_getNCCGC]
AS
SET NOCOUNT ON;

BEGIN TRY
	--//NCC GC ORDERS
	select orderNo, orderTotal, membershipType, orderDate
	from tblOrders where orderID IN
	(select distinct orderID from tblOrders_Products
	where productCode like 'NC%'
	and productCode like '%6-%'
	and productCode not like '%EV%')
	and orderStatus<>'cancelled' and orderStatus<>'failed'
	and storeID=4 --69
	and orderDate>convert(datetime,'10/10/12')

	--//NCC GC PRODUCTS TAB
	select productCode, productName, sum(productQuantity*productPrice) as 'Price', sum(productQuantity) as 'QTY'
	from tblOrders_Products 
	where deleteX<>'yes'
	and productCode like 'NC%'
	and productCode like '%6-%'
	and productCode not like '%EV%'
	and orderID IN
	(select orderID  from tblOrders where 
	orderStatus<>'cancelled' and orderStatus<>'failed'
	and storeID=4 --69
	and orderDate>convert(datetime,'10/10/12'))
	group by productCode, productName

	--// NCC GC CAUSES
	select textValue, count(textValue) 
	from tblOrdersProducts_productOptions 
	where optionCaption='Cause'
	and deleteX<>'yes'
	group by textValue
	order by textValue ASC

	--// NCC GC #Cards/Cause
	select sum(a.productQuantity), b.textValue from tblORders_Products a INNER JOIN tblOrdersProducts_productOptions b
	on a.[ID]=b.ordersProductsID
	where a.deleteX<>'yes' 
	and b.deleteX<>'yes'
	and b.optionCaption='Cause'
	and a.orderID in
	(select orderID from tblOrders where orderStatus<>'cancelled' and orderStatus<>'failed')
	group by b.textValue
	order by b.textValue ASC

	--// NCC GC EMAILS
	select distinct email from tblCustomers
	where customerID in
	(select distinct customerID from tblOrders where 
	orderStatus<>'cancelled' and orderStatus<>'failed'
	and storeID=4 --69
	and orderDate>convert(datetime,'10/10/12')
	and orderID in
	(select distinct orderID from tblOrders_Products
	where deleteX<>'yes'
	and productCode like 'NC%'
	and productCode like '%6-%'
	and productCode not like '%EV%'))

	--// NCC TRANX
	select productName, COUNT(productName)
	from tblOrders_Products 
	where deleteX<>'yes'
	and productCode like 'NC%'
	and productCode like '%6-%'
	and productCode not like '%EV%'
	and orderID IN
	(select orderID  from tblOrders where 
	orderStatus<>'cancelled' and orderStatus<>'failed'
	and storeID=4 --69
	and orderDate>convert(datetime,'10/10/12'))
	group by productName
	order by productName ASC

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH