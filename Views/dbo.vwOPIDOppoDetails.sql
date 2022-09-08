











CREATE VIEW [dbo].[vwOPIDOppoDetails]
AS
-- returns pivoted oppo data for all opids in tblOPIDProductionProcess
	WITH cteOppos as (
		SELECT DISTINCT oppo.ordersProductsID,op.productCode,op.productName,oppo.optioncaption,oppo.textvalue
		FROM tblOPIDProductionProcess opp
		INNER JOIN tblOrders_Products op on opp.opid = op.id
		INNER JOIN tblOrdersProducts_ProductOptions oppo on oppo.ordersProductsid = op.id
		left join tblProduct_ProductOptions ppo on ppo.productID = op.productid and oppo.optionID = ppo.optionID
		left join tblProductOptions po 	on oppo.optionCaption = po.optionCaption
		WHERE oppo.deletex <> 'yes'
	),
	cteProducts as (
	SELECT distinct o.ordersProductsID,o.productName,o.productCode
		,op.textValue as CanvasPreviewFront
		,ISNULL(oc.textValue,'') as CompanyName
		,ISNULL(os.textValue,'') as Size
		,ISNULL(og.textValue,'') as Gender
		,ISNULL(ol.textValue,'') as Color
		,ISNULL(oi.textValue,'') as CompanyID
		,CASE WHEN oe.ordersProductsID IS NOT NULL then 'Yes' ELSE '' END as ExpressProduction
		,ISNULL(oa.textValue,'') as ApparelLogo
	FROM (select distinct ordersProductsID,productName,productCode FROM cteoppos) o
	LEFT JOIN cteOppos op on o.ordersProductsID = op.ordersProductsID AND  op.optionCaption = 'CanvasPreviewFront'
	LEFT JOIN cteOppos oc on o.ordersProductsID = oc.ordersProductsID and oc.optionCaption = 'Company Name'
	LEFT JOIN cteOppos oi on o.ordersProductsID = oi.ordersProductsID and oi.optionCaption = 'GBSCompanyId'
	LEFT JOIN cteOppos os on o.ordersProductsID = os.ordersProductsID and os.optionCaption = 'Size'
	LEFT JOIN cteOppos og on o.ordersProductsID = og.ordersProductsID and og.optionCaption = 'Gender'
	LEFT JOIN cteOppos ol on o.ordersProductsID = ol.ordersProductsID and ol.optionCaption = 'ApparelColor'
	LEFT JOIN cteOppos oe on o.ordersProductsID = oe.ordersProductsID and oe.optionCaption = 'Express Production' AND (oe.textValue LIKE 'Yes%' OR oe.textValue LIKE 'Express%' OR ISNULL(oe.textValue,'') = '')
	LEFT JOIN cteOppos oa on o.ordersProductsID = oa.ordersProductsID and oa.optionCaption = 'EMB Logo'
	)

	select distinct ordersProductsID as OPID
		,productName
		,CanvasPreviewFront
		,CompanyName
		,p.Size
		,p.Gender
		,ExpressProduction
		,CompanyID
		,ApparelLogo
		,p.productCode
	FROM cteProducts p