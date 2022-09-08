CREATE PROCEDURE [dbo].[Report_OrdersNotMigrated]
	AS
	SELECT gbsOrderID AS OrderNo, CreateDate AS OrderDate, nopId as NopOrderId
	FROM dbo.nopcommerce_tblNopOrder o 
	left join tblorders d on d.orderno = o.gbsorderid
	where d.orderno is null
		AND createDate > '2021-01-01'
	order by o.createdate desc