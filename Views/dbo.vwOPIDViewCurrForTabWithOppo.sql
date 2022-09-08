












CREATE VIEW [dbo].[vwOPIDViewCurrForTabWithOppo]
AS
-- base fields for intranet tabs
WITH cteTicTicDir AS (
	SELECT variableValue FROM EnvironmentVariables WHERE VariableName = 'TicTicDirectory'
)
SELECT DISTINCT ovt.id
	,ovt.workflowID
	,ovt.productCode
	,ovt.productQuantity
	,ovt.[orderNo] 
	,ovt.[orderID]
	,ovt.[orderStatus]
	,ovt.[lastStatusUpdate]
	,ovt.[orderDate]
	,ovt.GBSCompany
	,ovt.customerID
    ,ovt.firstName
	,ovt.surName
	,ood.CanvasPreviewFront
	,ood.CompanyName
	,ood.Size
	,ood.Gender
	,ood.ExpressProduction
	,ood.CompanyID
	,ood.ApparelLogo
	,ttd.variableValue +  substring(ovt.orderNo,4,len(ovt.orderNo)) + '_' + cast(ovt.id as varchar(15)) + '_tictic.pdf' AS TicTicDirectory
FROM vwOPIDViewCurrForTab ovt
LEFT JOIN dbo.vwOPIDOPPODetails ood on ood.opid = ovt.id
CROSS APPLY (select * from cteTicTicDir) ttd