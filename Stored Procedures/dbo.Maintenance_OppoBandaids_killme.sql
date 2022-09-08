CREATE PROCEDURE [dbo].[Maintenance_OppoBandaids_killme]
AS


--grommet pricing is not right. fix it
UPDATE oppo
set optionPrice = case when optionCaption = 'add 2 grommets' then 1 
			when optionCaption = 'Add 4 Grommets' then 2
			end
FROM tblOrdersProducts_ProductOptions oppo
inner join tblOrders_Products op on op.id = oppo.ordersProductsID
inner join tblorders o on o.orderid = op.orderID 
WHERE optionCaption LIKE '%grommets%'
and oppo.created_on > '2/5/2021'
AND oppo.deletex <> 'yes'
and exists (select * from tblorders c where displayPaymentStatus =  'Credit Due' and c.orderid = o.orderid)
AND ISNULL(optionPrice,0) NOT IN (2, 1)


--without this the files loaded for name badge setup will not work
UPDATE oppo
SET textvalue =  '<a href="http://www.houseofmagnets.com/download/getfileupload/?downloadId=' + textValue + '" class="fileuploadattribute">link</a>'
FROM tblordersproducts_productoptions oppo
where optioncaption = 'Upload Vector File'
AND created_on > '2/5/2021'
AND textvalue not like '<a %'


/*
Need to fix this. It deadlocks

	--remove the blank envelope file oppos.  The only file oppos that should be kept are the ones 
	--for the address placement.
	UPDATE oppo
	SET deleteX = 'yes'
	FROM tblOrdersProducts_ProductOptions oppo
	INNER JOIN (
		SELECT ordersProductsID, textValue 
		FROM tblOrdersProducts_ProductOptions 
		WHERE optioncaption = 'Return Address Placement'
	) a ON a.ordersProductsID = oppo.ordersProductsID
	WHERE oppo.optionCaption LIKE '%CanvasHiResEnvelope%' --this is going to come back and bite when we change this name
		AND optionCaption NOT LIKE '%'+TRIM(LEFT(a.textValue,5))+ '%'
		AND oppo.deletex <> 'yes'


		*/