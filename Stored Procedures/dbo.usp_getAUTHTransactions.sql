CREATE PROC [dbo].[usp_getAUTHTransactions] 

@startDate varchar(255),
@endDate varchar(255)

as
declare @startDateConverted datetime
declare @endDateConverted datetime

set @startDateConverted=(convert(datetime,@startDate))
set @endDateConverted=(convert(datetime,@endDate))

select @startDate, @endDate, 
a.batchDate, a.orderID, a.orderNo, a.paymentAmount, a.paymentDate, a.responseCode, a.cardName, a.cardType, a.authorizationCode, a.invoiceDescription, a.actionCode
from tblTransactions a
where a.responseCode=1 and a.actionCode<>'void' and a.batchDate>=@startDateConverted and a.batchDate<=@endDateConverted

select @startDate, @endDate, 
sum(a.paymentAmount) as 'totalSales', count(distinct(a.paymentID)) as 'totalOrders'
from tblTransactions a
where a.responseCode=1 and a.actionCode<>'void' and a.batchDate>=@startDateConverted and a.batchDate<=@endDateConverted