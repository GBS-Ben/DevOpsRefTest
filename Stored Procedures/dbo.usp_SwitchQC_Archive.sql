CREATE PROCEDURE [dbo].[usp_SwitchQC_Archive]
AS
SET NOCOUNT ON;

BEGIN TRY

	--// Initial Updates
	UPDATE tblSwitch_QC
	SET productQuantity = b.productQuantity, 
	productName = b.productName, 
	productCode = b.productCode, 
	groupID = b.groupID, 
	mo_orders_Products = b.modified_on
	FROM tblSwitch_QC a
	INNER JOIN tblOrders_Products b ON a.ordersProductsID = b.[ID] 

	--// tblCustomers_ShippingAddress
	UPDATE tblSwitch_QC
	SET shipCompany = b.shipping_company, 
	shipFirstName = b.shipping_firstName, 
	shipLastName = b.shipping_surName, 
	shipAddress1 = shipping_street, 
	shipAddress2 = shipping_street2, 
	shipCity = b.shipping_suburb, 
	shipState = b.shipping_state, 
	shipZip = b.shipping_postCode, 
	shipCountry = b.shipping_country, 
	shipPhone = b.shipping_phone, 
	mo_customers_ShippingAddress = b.modified_on
	FROM tblSwitch_QC a
	INNER JOIN tblCustomers_ShippingAddress b ON a.shippingAddressID = b.shippingAddressID
	WHERE  a.mo_customers_ShippingAddress <> b.modified_on
	AND a.mo_customers_ShippingAddress <> b.created_on
	AND a.mo_customers_ShippingAddress IS NOT NULL
	AND b.modified_on IS NOT NULL

	--// insert new records into tblSwitch_QC
	INSERT INTO tblSwitch_QC (orderID, orderNo, orderDate, customerID, 
	shippingAddressID, shipCompany, shipFirstName, shipLastName, shipAddress1, shipAddress2, shipCity, shipState, shipZip, shipCountry, shipPhone, 
	ordersProductsID, productID, productCode, productName, productQuantity, groupID, 
	mo_orders_Products, mo_orders, mo_customers_ShippingAddress, 
	switch_create, switch_import)

	SELECT
	a.orderID, a.orderNo, a.orderDate, a.customerID, 
	s.shippingAddressID, s.shipping_Company, s.shipping_Firstname, s.shipping_surName, 
	s.shipping_Street, s.shipping_Street2, 
	s.shipping_Suburb, s.shipping_State, s.shipping_PostCode, 
	s.shipping_Country, s.shipping_Phone, 
	p.[ID], p.productID, p.productCode, p.productName, p.productQuantity, p.groupID, 
	p.modified_on, a.modified_on, s.modified_on, 
	1, 1
	FROM tblOrders a
	INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
	INNER JOIN tblOrders_Products p ON a.orderID = p.orderID
	WHERE
	a.orderStatus <> 'cancelled' AND a.orderStatus <> 'failed' AND a.orderStatus <> 'delivered'
	AND a.orderStatus <> 'In Transit' AND a.orderStatus NOT LIKE '%Waiting%'
	AND p.deleteX <> 'yes'
	AND SUBSTRING(p.productCode, 3, 3) = 'QC1'
	AND p.[ID] NOT IN 
		(SELECT DISTINCT ordersProductsID 
		FROM tblSwitch_QC 
		WHERE ordersProductsID IS NOT NULL)
	AND DATEDIFF(MI, a.orderDate, getDate()) > 30

	--// Clean phone field
	UPDATE tblSwitch_QC
	SET shipPhone = '(' + SUBSTRING(shipPhone, 1, 3) + ')' + SUBSTRING(shipPhone, 4, 3) + '-' + SUBSTRING(shipPhone, 7, 4)
	WHERE shipPhone NOT LIKE '(%'

	--// determine shipsWith value
	-- 1. if order contains at least one custom product, and any varying QTY of any other product types, label "Ships With Custom"
	UPDATE tblSwitch_QC
	SET shipsWith = 'Ships With Custom'
	WHERE orderID IN
		(SELECT DISTINCT orderID 
		FROM tblOrders_Products 
		WHERE deleteX <> 'yes'
		AND orderID IS NOT NULL
		AND SUBSTRING(productCode, 3, 3) <> 'QC1'
		AND productID IN
			 (SELECT DISTINCT productID 
			 FROM tblProducts 
			 WHERE productType = 'Custom' 
			 AND productName NOT LIKE '%envelope%' 
			 AND productID IS NOT NULL)
		 )

	-- 2. if order contains stock product(s) but no custom product(s), label "Ships With Stock"
	UPDATE tblSwitch_QC
	SET shipsWith = 'Ships With Stock'
	WHERE shipsWith IS NULL
	AND orderID IN
		(SELECT DISTINCT orderID 
		FROM tblOrders_Products 
		WHERE deleteX <> 'yes'
		AND orderID IS NOT NULL
		AND SUBSTRING(productCode, 3, 3) <> 'QC1'
		AND productID IN
			 (SELECT DISTINCT productID 
			 FROM tblProducts 
			 WHERE productType = 'Stock' 
			 AND productName NOT LIKE '%envelope%' 
			 AND productID IS NOT NULL)
		 )

	-- 3. otherwise, if order contains only primary product, then put the barcoded ONHOM123456 in
	UPDATE tblSwitch_QC
	SET shipsWith = 'ON' + orderNo
	WHERE shipsWith IS NULL

	--// Products
	UPDATE tblSwitch_QC
	SET parentProductID = b.parentProductID, 
	numUnits = b.numUnits
	FROM tblSwitch_QC a
	INNER JOIN tblProducts b
		ON a.productID = b.productID

	--// Fix Quantities
	UPDATE tblSwitch_QC
	SET displayedQuantity = productQuantity * numUnits

	--// Populate shortName column
	UPDATE tblSwitch_QC
	SET shortName = rtrim(substring(productName, 1, (SELECT CHARINDEX('(', productName)-1)))
	WHERE shortName is NULL
	OR shortName = ''

	UPDATE tblSwitch_QC
	SET shortName = replace(shortName, (substring(shortName, 1, (SELECT CHARINDEX('-', productName) + 1))), '')
	WHERE shortName like '%-%'
	AND shortName is NOT NULL

	--// Update OPPO fields
	UPDATE tblSwitch_QC
	SET variableTopName = b.textValue
	FROM tblSwitch_QC a
	INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE  b.textValue LIKE '%.pdf%'
	AND b.deleteX <> 'yes'
	AND b.optionCaption = 'File Name 2'

	UPDATE tblSwitch_QC
	SET backName = b.textValue
	FROM tblSwitch_QC a
	INNER JOIN tblOrdersProducts_productOptions b ON a.ordersProductsID = b.ordersProductsID
	WHERE b.deleteX <> 'yes'
	AND b.optionCaption = 'Product Back'

	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--// Counts (do multiCount and totalCount with FOR WHILE Loop)
	 IF OBJECT_ID(N'tempGC_Count', N'U') IS NOT NULL
	 DROP TABLE tempGC_Count

	 CREATE TABLE tempGC_Count (
	 RowID int IDENTITY(1, 1), 
	 orderNo VARCHAR(255), 
	 ordersProductsID int, 
	 multiCount int
	 )
	 DECLARE @NumberRecords int, @RowCount int
	 DECLARE @orderNo VARCHAR(255)
	 DECLARE @ordersProductsID int
	 DECLARE @totalCount int
	 DECLARE @multiCount int

	 -- Insert the resultset we want to loop through into the temporary table
	 INSERT INTO tempGC_Count (orderNo, ordersProductsID, multiCount)
	 SELECT DISTINCT orderNo, ordersProductsID, 
	 ROW_NUMBER() OVER (PARTITION BY orderNO ORDER BY ordersProductsID) AS 'multiCount'
	 FROM tblSwitch_QC
	 WHERE orderNo IS NOT NULL
			AND productName NOT LIKE '%Envelope%'
	 ORDER BY orderNo, ordersProductsID

	 -- Get the number of records in the temporary table
	 SET @NumberRecords = @@ROWCOUNT
	 SET @RowCount = 1

	 -- loop through all records in the temporary table using the WHILE loop construct
	 WHILE @RowCount < = @NumberRecords
	 BEGIN

	 SELECT @orderNo = orderNo, @ordersProductsID = ordersProductsID, @multiCount = multiCount
	 FROM tempGC_Count
	 WHERE RowID = @RowCount

	 SET @totalCount = (SELECT COUNT(orderNo) 
						FROM tblSwitch_QC 
						WHERE orderNo = @orderNo)

	 UPDATE tblSwitch_QC
	 SET totalCount = @totalCount, multiCount = @multiCount
	 WHERE ordersProductsID = @ordersProductsID

	 SET @RowCount = @RowCount + 1
	 END
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	-- remove deleted products
	DELETE FROM tblSwitch_QC
	WHERE ordersProductsID IN
	(SELECT DISTINCT [ID] FROM tblOrders_Products WHERE deleteX = 'yes')

	-- fix blank totalCounts and multiCounts so that they are not null.
	UPDATE tblSwitch_QC
	SET totalCount = 0
	WHERE totalCount IS NULL

	UPDATE tblSwitch_QC
	SET multiCount = 0
	WHERE multiCount IS NULL


	-- set import flags and make new line items available to switch
	UPDATE tblSwitch_QC
	SET switch_create = 0
	WHERE switch_create is NULL or switch_create = ''

	UPDATE tblSwitch_QC
	SET switch_create = 0
	WHERE switch_import = 1

	UPDATE tblSwitch_QC
	SET switch_import = 0
	WHERE switch_import = 1

	-- displayCount creation
	UPDATE tblSwitch_QC
	SET displayCount = CONVERT(VARCHAR(50), multiCount) + ' of ' + CONVERT(VARCHAR(50), totalCount)
	WHERE multiCount IS NOT NULL
	AND totalCount IS NOT NULL


	--// shipType Update
	--// default
	UPDATE tblSwitch_QC
	SET shipType = 'SHIP'
	WHERE shipType IS NULL

	--// 3 day
	UPDATE tblSwitch_QC
	SET shipType = '3 Day'
	WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) = 9
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%3%')

	--// 2 day
	UPDATE tblSwitch_QC
	SET shipType = '2 Day'
	WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) = 9
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%2%')

	--// next day
	UPDATE tblSwitch_QC
	SET shipType = 'Next Day'
	WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE LEN(orderNo) = 9
	AND CONVERT(VARCHAR(255), shippingDesc) LIKE '%next%')

	--// local pickup, will call
	UPDATE tblSwitch_QC
	SET shipType = 'Local Pickup'
	WHERE orderNo IN
	(SELECT DISTINCT orderNo
	FROM tblOrders
	WHERE 
	LEN(orderNo) = 9 AND (CONVERT(VARCHAR(255), shippingDesc) LIKE '%local%' OR CONVERT(VARCHAR(255), shippingDesc) LIKE '%will%')
	OR LEN(orderNo) = 9 AND (CONVERT(VARCHAR(255), shipping_firstName) LIKE '%local pickup%')
	)

	--------------------//
	UPDATE tblSwitch_QC SET switch_approve = 0
	UPDATE tblSwitch_QC SET switch_print = 0
	UPDATE tblSwitch_QC SET switch_approveDate = GETDATE()
	UPDATE tblSwitch_QC SET switch_printDate = GETDATE()
	UPDATE tblSwitch_QC SET switch_createDate = GETDATE()

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH