










CREATE VIEW [dbo].[vwOPIDViewWithOppo]
AS
WITH cteTicTicDir AS (
	SELECT variableValue FROM EnvironmentVariables WHERE VariableName = 'TicTicDirectory'
)
SELECT DISTINCT 
	 ov.*
	,ood.CanvasPreviewFront
	,ood.CompanyName
	,ISNULL(ood.Size,'') as Size
	,ISNULL(ood.Gender,'') as Gender
	,ood.ExpressProduction
	,ood.CompanyID
	,ood.ApparelLogo
	,ttd.variableValue +  substring(ov.orderNo,4,len(ov.orderNo)) + '_' + cast(ov.id as varchar(15)) + '_tictic.pdf' AS TicTicDirectory
FROM vwOPIDView ov
LEFT JOIN dbo.vwOPIDOPPODetails ood on ood.opid = ov.id
CROSS APPLY (select * from cteTicTicDir) ttd