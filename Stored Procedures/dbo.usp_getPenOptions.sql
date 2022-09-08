
CREATE PROC usp_getPenOptions @productCode VARCHAR (255)

--////////////////////////////////////////////////////////////////////////////////////

/*
** Name: usp_getPenOptions
** Desc: gets pen options in format that Alex K. requested for pen page
** Auth: Jeremy Fifer
** Date: 5/7/2015
**************************
** Change History
**************************
** PR   Date	    Author  Description	
** --   --------   -------   ------------------------------------
** n/a
*/

AS
DECLARE @features VARCHAR (255),
@barrelOption VARCHAR (255),
@inkOption VARCHAR (255)

--// FEATURES
SET @features = 
(
SELECT optionCaption 
FROM tblProductOptions
WHERE 
optionGroupID IN
(SELECT DISTINCT optionGroupID
FROM tblProductOptionGroups
WHERE optionGroupID IS NOT NULL
AND optionGroupCaption = 'Features' 
)
AND optionID IN
	(SELECT optionID
	FROM tblProduct_productOptions p
	WHERE optionID IS NOT NULL
	AND productID IN
		(SELECT DISTINCT productID
		FROM tblProducts
	    WHERE productID IS NOT NULL
		AND productCode = @productCode
		)
	)
)

--// BARREL OPTION
SET @barrelOption = 
(
SELECT optionCaption 
FROM tblProductOptions
WHERE 
optionGroupID IN
(SELECT DISTINCT optionGroupID
FROM tblProductOptionGroups
WHERE optionGroupID IS NOT NULL
AND optionGroupCaption = 'Barrel Option' 
)
AND optionID IN
	(SELECT optionID
	FROM tblProduct_productOptions p
	WHERE optionID IS NOT NULL
	AND productID IN
		(SELECT DISTINCT productID
		FROM tblProducts
	    WHERE productID IS NOT NULL
		AND productCode = @productCode
		)
	)
)

--// INK OPTION
SET @inkOption = 
(
SELECT optionCaption 
FROM tblProductOptions
WHERE 
optionGroupID IN
(SELECT DISTINCT optionGroupID
FROM tblProductOptionGroups
WHERE optionGroupID IS NOT NULL
AND optionGroupCaption = 'Ink Option' 
)
AND optionID IN
	(SELECT optionID
	FROM tblProduct_productOptions p
	WHERE optionID IS NOT NULL
	AND productID IN
		(SELECT DISTINCT productID
		FROM tblProducts
	    WHERE productID IS NOT NULL
		AND productCode = @productCode
		)
	)
)

IF @features IS NULL
	BEGIN
		SET @features = ''
	END

IF @barrelOption IS NULL
	BEGIN
		SET @barrelOption = ''
	END

IF @inkOption IS NULL
	BEGIN
		SET @inkOption = ''
	END


SELECT @productCode as 'productCode',
@features + ' ' + @barrelOption + ' ' + @inkOption AS 'optionCaption'

/*
PRINT @features
PRINT @barrelOption
PRINT @inkOption
*/
--////////////////////////////////////////////////////////////////////////////////////