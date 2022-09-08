CREATE PROCEDURE [dbo].[usp_marketing_StaticVoucherRevenue]
	@StartDate DATE
	,@EndDate DATE


AS
-------------------------------------------------------------------------------
-- Author		Craig Price 
-- Created		07/14/16
-- Purpose		Returns  static voucher revenue report for a Google Analytics data validation
-- Sample		EXEC usp_marketing_StaticVoucherRevenue '07/12/2016', '07/14/2016'
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/14/16		Initialized.
-------------------------------------------------------------------------------

SELECT s.orderID
	,orderNo
		,paymentMethod
		,orderTotal
		,orderDate
		,ipaddress
		, svouchercode as 'Voucher'
FROM tblOrders_Static as s
LEFT JOIN tblVouchersSalesUse su ON su.OrderID = s.OrderId
WHERE cast(orderDate as Date) between @StartDate and @EndDate
	AND s.orderid not in (select orderid 
				       from tblOrders_Static
					   WHERE cast(orderDate as date) between @StartDate and @EndDate
						AND paymentMethodID = 1 
						AND paymentSuccessful = 0)
order by svouchercode desc
	,orderdate