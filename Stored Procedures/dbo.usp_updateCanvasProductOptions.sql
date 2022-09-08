CREATE PROC [dbo].[usp_updateCanvasProductOptions] 

@webPlatform varchar(100),
@surfaceType varchar(100),
@productType varchar(100),
@fileName varchar(100),
@OPID int

AS
--04/27/21		CKB, Markful

INSERT INTO tblOrdersProducts_productOptions (ordersProductsID,optionID,optionCaption,optionPrice,optionGroupCaption,textValue,deletex)

SELECT b.ID,
CASE WHEN @webPlatform = 'NOP' THEN 535
WHEN (@webPlatform IN ('HOM','MRK') AND @surfaceType = 'FRONT') THEN 539
ELSE 546 END AS optionID,

CASE WHEN @webPlatform = 'NOP' AND @surfaceType = 'FRONT' AND @productType = 'NOTECARD' THEN 'Card Front'
WHEN @webPlatform = 'NOP' AND @surfaceType = 'BACK' AND @productType = 'NOTECARD' THEN 'Card Back'
WHEN @webPlatform = 'NOP' AND @surfaceType = 'GREETING' AND @productType = 'NOTECARD' THEN 'Greeting'
WHEN @webPlatform = 'NOP' AND @surfaceType = 'FRONT' AND @productType = 'ENVELOPE' THEN 'Envelope Front'
WHEN @webPlatform = 'NOP' AND @surfaceType = 'BACK' AND @productType = 'ENVELOPE' THEN 'Envelope Back'
WHEN @webPlatform IN ('HOM','MRK') AND @surfaceType = 'FRONT' THEN 'Intranet PDF'
WHEN @webPlatform IN ('HOM','MRK') AND @surfaceType = 'BACK' THEN 'Back Intranet PDF'
ELSE '' END AS optionCaption,

0.00,'Custom Info',@fileName AS textValue,0
FROM tblOrders_Products b
WHERE b.ID=@OPID
AND NOT EXISTS (SELECT * FROM tblOrdersProducts_productOptions a
	WHERE deletex <> 'yes' AND ordersProductsID=@OPID
	AND (
    (a.optionID=535 AND a.optionCaption LIKE '%'+@surfaceType+'%' AND @productType = 'NOTECARD' AND @webPlatform = 'NOP')
	OR (a.optionID=535 AND a.optionCaption LIKE '%'+@surfaceType+'%' AND @productType = 'ENVELOPE' AND @webPlatform = 'NOP')
    OR (@surfaceType = 'FRONT' AND a.optionID=539 AND @webPlatform IN ('HOM','MRK'))
	OR (@surfaceType = 'BACK' AND a.optionID=546 AND @webPlatform IN ('HOM','MRK'))
	)
)