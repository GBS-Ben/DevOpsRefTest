create view SwitchBatchLogParse_SN as
select flowName
,a.PKID
,a.ordersProductsID
,a.batchTimestamp
,b.*
--,a.jsonData
from dbo.tblSwitchBatchLog a
cross apply openjson(jsonData) 
with 
(json_ordersProductsID int '$.ordersProductsID'
,json_orderID int '$.orderID'
,json_orderNo nvarchar(50) '$.orderNo'
,json_fileName_front nvarchar(255) '$.fileName_front'
,json_fileName_back nvarchar(255) '$.fileName_back'
,json_presentedToSwitch bit '$.presentedToSwitch'
,json_presentedToSwitch_on datetime '$.presentedToSwitch_on'
,json_created_on datetime '$.created_on'
,json_modified_on datetime '$.modified_on'
,json_customDataSynced bit '$.customDataSynced'
,json_isPrepped bit '$.isPrepped'
) as b
where flowName = 'SN'