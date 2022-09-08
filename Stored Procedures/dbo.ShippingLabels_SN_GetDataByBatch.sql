CREATE proc [dbo].[ShippingLabels_SN_GetDataByBatch] 
@batchTimestamp datetime
as
begin

with SignByOpid as
(
SELECT distinct
[orderNo]
,[orderID]
,[opid]
,[orderDate]
,[orderPrintedDate]
,[batchImpo]
,[orderStatus]
,[shipping_Company]
,[shipping_FirstName]
,[shipping_Surname]
,[shipping_Street]
,[shipping_Suburb]
,[shipping_State]
,[shipping_PostCode]
,[productCode]
,[productQuantity]
,[frontPdf]
,[backPdf]
,[size]
,[jobNumber]
,[bottomLabel1]
,[bottomLabel2]
,[squareLabel]
,[circleLabel]
,[stockProducts]
,[fastTrackResubmit]
FROM [dbo].[SN_ImposerExport_Label]
WHERE [batchTimestamp] = @batchTimestamp
)

select *
,signXofX = right('00' + rtrim(cast(ROW_NUMBER() over (partition by orderNo order by opid) as varchar(2))),2) + ' of ' + right('00' + rtrim(cast(count(opid) over (partition by orderNo) as varchar(2))),2)
from SignByOpid



end