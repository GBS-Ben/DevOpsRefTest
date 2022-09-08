CREATE PROC [dbo].[Dashboard_VoucherUsers]
@VoucherCode varchar(255) = '',
@OrderDate datetime = '1/1/1990'
AS
BEGIN

	select distinct vsu.svouchercode,o.orderno as [Order Number]
	,o.orderdate as [Date]
	,c.company as [Company]
	,c.FirstName + ' ' + c.SurName as [Customer Name]
	,c.email as [email]
	,c.street as Address1
	,c.street2 as Address2
	,c.suburb as City
	,c.state as [State]
	,c.postcode as Zip
	,c.phone as [Phone Number]
	,o.ordertotal as 'Revenue'
	from tblorders o 
	inner join tblVouchersSalesUse vsu on o.orderid = vsu.OrderId 
	left join tblCustomers c on o.CustomerId = c.customerid
--	left join tblCustomers_BillingAddress ba on o.orderno = ba.orderno and c.customerid = ba.CustomerID
	where (select case when @VoucherCode <> '' and vsu.svouchercode like @VoucherCode then 1
                       when @VoucherCode = '' then 1 else 0 end) = 1				
	and o.orderdate >= @OrderDate
	order by o.orderdate desc

END