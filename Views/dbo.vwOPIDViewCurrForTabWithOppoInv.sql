











CREATE VIEW [dbo].[vwOPIDViewCurrForTabWithOppoInv]
AS
-- base fields for intranet tabs
SELECT DISTINCT ood.id
	,ood.workflowID
	,ood.productCode
	,ood.productQuantity
	,ood.[orderNo] 
	,ood.[orderID]
	,ood.[orderStatus]
	,ood.[lastStatusUpdate]
	,ood.[orderDate]
	,ood.GBSCompany
	,ood.customerID
    ,ood.firstName
	,ood.surName
	,ood.CanvasPreviewFront
	,ood.CompanyName
	,ood.Size
	,ood.Gender
	,ood.ExpressProduction
	,ood.CompanyID
	,ood.ApparelLogo
	,ood.TicTicDirectory
	,oi.Color
	,oi.GTIN
	,oi.catalogNo
	,oi.sanmarqty
	,oi.pendingQuantity
	,oi.availableQuantity
FROM vwOPIDViewCurrForTabWithOppo ood
LEFT JOIN dbo.vwOPIDInventory oi on ood.id = oi.opid