CREATE proc [dbo].[getCanvasLinkInfo] @OPID nvarchar(20)

as 

DECLARE @OrderOffset INT ;
EXEC EnvironmentVariables_Get N'idOffSet',@VariableValue = @OrderOffset OUTPUT;

SELECT
    --json_value(json_query(ccd.data,'$[0]'),'$')
    op.id as ordersproductsID
    ,replace(ccdjsondata.[key], '-stateId' COLLATE SQL_Latin1_General_Cp1_CI_AS, '') AS idType
    ,substring(convert(NVARCHAR(255), newid()), 1, 24) + 's' + convert(NVARCHAR(25), downloadurls.[key] + 1) + '.pdf' AS filename
    --,ccdjsondata.[value] as stateID
    --,downloadurls.[key]    as DownloadURLSKey
    ,o.orderNo
    ,downloadurls.[value] AS DownloadURLS
    ,getdate()

FROM tblorders_products op
INNER JOIN tblOrders o ON o.orderID = op.orderID
INNER JOIN [dbo].[nopCommerce_tblNOPOrderItem] nOI ON nOI.nopOrderItemID = op.id - @OrderOffset
INNER JOIN [dbo].[nopCommerce_CCDesign] ccD ON ccD.Id = nOI.ccid
LEFT JOIN tblNOPProductionFiles npf ON op.id = npf.nopOrderItemID
CROSS APPLY openjson(ccd.data) AS ccdjsonData
CROSS APPLY openjson(ccd.downloadurlsJson) AS downloadurls
WHERE op.id = @OPID