CREATE VIEW [dbo].[vwProductCategory]
AS
SELECT op.ID as ordersProductsID,op.productCode,op.productName,op.processType,
	CASE WHEN op.ProductCode LIKE 'NB__S%' THEN 'SNB'
		 WHEN op.ProductCode LIKE 'BP%' AND (textValue NOT LIKE '%32%pt%' OR textValue NOT LIKE '%52%pt%') THEN 'BC'
		 WHEN op.ProductCode LIKE 'SN%'     THEN 'SN'
		 WHEN op.ProductCode LIKE 'GN%'     THEN 'NPad'
		 WHEN op.ProductCode LIKE 'CAC%'    THEN 'CP'
		 WHEN op.ProductCode LIKE 'PL%'     THEN 'Nam'
		 WHEN op.ProductCode LIKE 'AP%'     THEN 'AP'
		 WHEN op.ProductCode LIKE '__QS%'   THEN 'QS'
		 WHEN op.ProductCode LIKE '%EV%'    THEN 'ENV'
		 WHEN op.ProductCode LIKE 'CM%'     THEN 'CM'
		 WHEN op.ProductCode LIKE 'BP%' AND (textValue LIKE '%32%pt%' ) THEN '32pt'
		 WHEN op.ProductCode LIKE 'BP%' AND (textValue LIKE '%52%pt%') THEN '52pt'
		 WHEN op.ProductCode LIKE '__QC%'     THEN 'QC'
		 WHEN (op.ProductCode LIKE '__QM%' OR op.ProductCode LIKE '__EX%' OR op.ProductCode LIKE '__FC%' OR op.ProductCode LIKE '__JU%') THEN 'Mag'
		 WHEN op.ProductCode LIKE 'MK__FM%' THEN 'MK'
		 WHEN op.ProductCode LIKE 'MKNG%'   THEN 'GT'
		 WHEN op.processType = 'stock'		THEN 'Stock'
	ELSE 'OTH'
	END AS 'Category'
FROM tblOrders_Products op
LEFT JOIN  tblOrdersProducts_ProductOptions oppo  on op.ID = oppo.ordersProductsId AND oppo.optionCaption = 'Paper Stock'