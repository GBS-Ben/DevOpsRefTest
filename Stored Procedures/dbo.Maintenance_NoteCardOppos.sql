CREATE PROCEDURE [dbo].[Maintenance_NoteCardOppos]
AS

BEGIN

	DECLARE @tblDeletex TABLE (ordersProductsID INT, textValue nvarchar(4000));

	--hide greeting file oppos when there is no greeting
	;WITH NoGreeting AS (
		SELECT ordersProductsID 
		FROM tblOrdersProducts_ProductOptions oppo
		WHERE optionCaption = 'Add Greeting' 
			AND TextValue LIKE 'NO%' --- order by created_on desc
			AND deletex <> 'yes'
			AND created_on > '2/6/2021'
			) 
		UPDATE oppo
		SET deletex = 'yes'
		OUTPUT deleted.ordersProductsID,deleted.textValue INTO @tblDeletex
		FROM NoGreeting g
		INNER JOIN tblOrdersProducts_ProductOptions oppo 
			ON oppo.ordersProductsID = g.ordersProductsID
		WHERE optionCaption LIKE '%Inside%'
			AND deletex <> 'yes'
			AND NOT EXISTS (
						--doubl check that another Add Greeting isn't YES for the same OPID
						SELECT top 1 1 
						FROM tblOrdersProducts_ProductOptions 
						WHERE  optionCaption = 'Add Greeting' 
							AND TextValue LIKE 'YES%' --- order by created_on desc
							AND ordersProductsID = oppo.ordersProductsID 
							AND deletex <>'yes')
							AND oppo.created_on > DATEADD(dd,-25,GETDATE())


	
	 --No Return Address - Hide all envelopes
	UPDATE  a
	SET  deletex = 'yes'  --select *
	OUTPUT deleted.ordersProductsID,deleted.textValue INTO @tblDeletex
	FROM  tblOrdersProducts_ProductOptions a 
	 WHERE optionCaption LIKE '%CanvasHiRes%Envelope%'
	 AND ordersProductsID > 2007000000
	 AND a.deletex <> 'Yes'
	 AND a.created_on > DATEADD(dd,-5,GETDATE())
	 AND NOT EXISTS(
				SELECT oppo.ordersProductsID
				FROM tblOrders o 
				INNER JOIN tblOrders_Products op ON op.OrderId=o.OrderId
				INNER JOIN tblOrdersProducts_ProductOptions oppo ON oppo.ordersProductsID = op.Id
				WHERE oppo.created_on > GETDATE() - 5
					AND ordersProductsID > 2007000000
					AND optionCaption  = 'Return Address Placement' --this is not there when address not selected
					AND oppo.deletex <> 'yes'
					AND o.OrderNo LIKE 'NCC%'
					AND a.ordersProductsID = oppo.ordersProductsID
		)


	 --Back, hide fronts
	 UPDATE  a
	SET deletex = 'yes'
	OUTPUT deleted.ordersProductsID,deleted.textValue INTO @tblDeletex
	FROM tblOrdersProducts_ProductOptions a 
	INNER JOIN (
	SELECT oppo.ordersProductsID
	FROM tblOrdersProducts_ProductOptions oppo
	WHERE created_on > GETDATE() - 5
		AND ordersProductsID > 2007000000
		AND optionCaption LIKE 'Return Address Placement'
		AND LEFT(TextValue,4) = 'Back'
		AND deletex <> 'yes'
	 ) g ON g.ordersProductsID = a.ordersProductsID
	 WHERE optionCaption LIKE '%Canvas%Envelope%Front%'
	 AND deletex <> 'Yes'

	 --front, hide backs
	 UPDATE  a
	SET deletex = 'yes'
	OUTPUT deleted.ordersProductsID,deleted.textValue INTO @tblDeletex
	FROM tblOrdersProducts_ProductOptions a 
	INNER JOIN (
	SELECT oppo.ordersProductsID
	FROM tblOrdersProducts_ProductOptions oppo
	WHERE created_on > GETDATE() - 5
		AND ordersProductsID > 2007000000
		AND optionCaption LIKE 'Return Address Placement'
		AND LEFT(TextValue,5) = 'Front'
		AND deletex <> 'yes'
	 ) g ON g.ordersProductsID = a.ordersProductsID
	 WHERE optionCaption LIKE '%Canvas%Envelope%Back%'
	 AND deletex <> 'Yes'

	DELETE fe
	FROM tblOPPO_fileExists fe
	INNER JOIN @tblDeletex t on fe.OPID = t.ordersProductsID and fe.textValue = t.textValue

END