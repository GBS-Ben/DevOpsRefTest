CREATE proc [dbo].[dashboard_DailyApparelOrders] as
begin

select 
[RunDate]
,[OrderNo]
,[OrderDate]
,[OPID]
,[productQuantity]
,[productName]
,[ApparelType]
,[Color]
,[Size]

from dbo.ReportData_DailyApparelOrders

order by RunDate desc, OrderDate desc, OPID



end