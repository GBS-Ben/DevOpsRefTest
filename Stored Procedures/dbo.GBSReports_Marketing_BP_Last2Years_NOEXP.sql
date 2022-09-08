create proc [dbo].[GBSReports_Marketing_BP_Last2Years_NOEXP] as

select distinct 
o.orderDate OrderDate
,o.orderNo OrderId
,left(op.productCode,2) Category
,op.productCode [ProductCode-SKU]
,case when CHARINDEX('(#',op.productName) > 1 then substring(op.productName,1,CHARINDEX('(#',op.productName) - 1) 
	else op.productName end ProductName
,c.email
,FirstName = coalesce(
	case 
	when CHARINDEX(' ',c.firstName) > 0
		then substring(c.firstName,1,CHARINDEX(' ',c.firstName))
		else c.firstName
		end,
	case 
	when CHARINDEX(' ',o.shipping_FirstName) > 0
		then substring(o.shipping_FirstName,1,CHARINDEX(' ',o.shipping_FirstName))
		else o.shipping_FirstName
		end)	
,LastName = coalesce(
	case
	when CHARINDEX(' ',reverse(rtrim(c.firstName))) > 0
		then substring(rtrim(c.firstname),(len(rtrim(c.firstName)) - CHARINDEX(' ',reverse(rtrim(c.firstName))) + 2),CHARINDEX(' ',reverse(rtrim(c.firstName))))
	else c.surname
	end,
	case
	when CHARINDEX(' ',reverse(rtrim(o.shipping_FirstName))) > 0
		then substring(rtrim(o.shipping_FirstName),(len(rtrim(o.shipping_FirstName)) - CHARINDEX(' ',reverse(rtrim(o.shipping_FirstName))) + 2),CHARINDEX(' ',reverse(rtrim(o.shipping_FirstName))))
	else o.shipping_Surname
	end)

,o.orderTotal [Order Total]
,op.productQuantity [Quantity]
,vsu.sVoucherCode [Discount Used]
,replace(cop.[Name],'- Select Your Office','') [Company]
,replace(co.[Name],'- Select Your Office','') [Office Name]
,op.GbsCompanyId [GbsCompanyId-Office]
,cop.GbsCompanyId [GbsCompanyId-Parent]
,[Full Name] = coalesce(
	rtrim(rtrim(c.firstName) + ' ' + rtrim(c.surname)),
	rtrim(rtrim(o.shipping_FirstName) + ' ' + rtrim(o.shipping_Surname)))


from dbo.tblOrders o
inner join dbo.tblOrders_Products op
	on o.orderID = op.orderID
inner join dbo.tblCustomers c
	on o.customerID = c.customerID
left join dbo.tblVouchersSalesUse vsu
	on o.orderID = vsu.orderID
left join dbo.tblCompany co
	on op.GbsCompanyId = co.GbsCompanyId
left join dbo.tblCompany cop
	on co.ParentCompanyId = cop.Id
where o.orderStatus not in ('Cancelled','Failed')
	and op.deletex <> 'yes'
	and left(op.productCode,2) = 'BP'
	and o.orderDate >= getdate() - 720

	and (op.productName not like 'exp%' and isnull(co.[Name],'') not like 'exp%')