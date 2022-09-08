create proc dashboard_SwitchProblemFiles as

select o.orderNo
,o.orderDate
,ofe.OPID
,op.productCode
,op.productName
,ofe.filePath
,ofe.textValue
,ofe.fileExists
,ofe.zeroBytes
,ofe.readyForSwitch

from dbo.tblOPPO_fileExists ofe
inner join dbo.tblOrders_Products op
	on ofe.OPID = op.ID
inner join dbo.tblOrders o
	on op.orderID = o.orderID

where ofe.readyForSwitch = 0 
and o.orderDate > (getdate() - 10)
order by o.orderDate desc