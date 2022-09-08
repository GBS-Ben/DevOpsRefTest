CREATE proc [dbo].[dashboard_DailySignOrders] as
begin

SELECT [RunDate]
,[OrderNo]
,[OrderDate]
,[OPID]
,[productQuantity]
,[Width]
,[Height]
,[MaterialType]
FROM [dbo].[ReportData_DailySignOrders]
order by RunDate desc, OrderDate desc, OPID

end