





CREATE proc [dbo].[usp_TicTic_AP_ProductData]
  @OPID int  
as
BEGIN TRY

	--declare @opid int = 556412413;

	declare @productId int = (select top 1 productID from tblOrders_Products where ID = @OPID);
	declare @productCode varchar(255) = (select top 1 stuff(productCode,9,1,'%') from tblOrders_Products where ID = @OPID);
	 
	WITH cteOppos as (
		SELECT oppo.ordersProductsID,oppo.optioncaption,oppo.textvalue
		FROM tblOrdersProducts_ProductOptions oppo
		left join tblProduct_ProductOptions ppo on ppo.productID = @productId and oppo.optionID = ppo.optionID
		left join tblProductOptions po 	on oppo.optionCaption = po.optionCaption
		WHERE oppo.ordersproductsID = @OPID
		AND oppo.deletex <> 'yes'
		and po.displayOntictic = 1
	),
	cteProducts as (
	SELECT DISTINCT o.ordersProductsID
		,ISNULL(op.textValue,'') as CanvasPreviewFront
		,ISNULL(oc.textValue,'') as CompanyName
		,ISNULL(os.textValue,'') as Size
		,ISNULL(og.textValue,'') as Gender
		,ISNULL(ol.textValue,'') as Color
		,CASE WHEN oe.ordersProductsID IS NOT NULL then 'Yes' ELSE '' END as ExpressProduction
	FROM cteOppos  o
	LEFT JOIN cteOppos op on o.ordersProductsID = op.ordersProductsID and op.optionCaption = 'CanvasPreviewFront'
	LEFT JOIN cteOppos oc on o.ordersProductsID = oc.ordersProductsID and oc.optionCaption = 'Company Name'
	LEFT JOIN cteOppos os on o.ordersProductsID = os.ordersProductsID and os.optionCaption = 'Size'
	LEFT JOIN cteOppos og on o.ordersProductsID = og.ordersProductsID and og.optionCaption = 'Gender'
	LEFT JOIN cteOppos ol on o.ordersProductsID = ol.ordersProductsID and ol.optionCaption = 'ApparelColor'
	LEFT JOIN cteOppos oe on o.ordersProductsID = oe.ordersProductsID and oe.optionCaption = 'Express Production' AND (oe.textValue LIKE 'Yes%' OR oe.textValue LIKE 'Express%' OR ISNULL(oe.textValue,'') = '')
	)
	select ordersProductsID
		,CanvasPreviewFront
		,CompanyName
		,p.Size
		,p.Gender
		,p.Color
		,ExpressProduction
		,pii.GTIN
		,pii.catalogNo
	FROM cteProducts p
	LEFT JOIN nopCommerce_vwTblProducts_InventorytopSanMar pii on  pii.skupattern = substring(STUFF(STUFF(@productCode,9,1,CASE p.Size 
																				WHEN 'XS' THEN 'T'
																                WHEN 'small' THEN 'S'
																                WHEN 'medium' THEN 'M'
																                WHEN 'large' THEN 'L'
																                WHEN 'XL' THEN 'X'
																                WHEN '2XL' THEN '2'
																                WHEN '3XL' THEN '3'
																                WHEN '4XL' THEN '4'
																                WHEN '5XL' THEN '5'
																				WHEN '' THEN '0' END),3,2,'__'),1,10) 

END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXECUTE [dbo].[usp_StoredProcedureErrorLog]

END CATCH

GO
