CREATE PROCEDURE [dbo].[GBSReports_OrdersNotMigrated] 
AS 

select 
tno.gbsOrderId
,tno.CreateDate
from dbo.nopcommerce_tblnoporder tno
left join dbo.tblOrders o on tno.gbsorderid = o.orderno
where o.orderNo is null and tno.createdate >= '1/1/21'
order by tno.createdate