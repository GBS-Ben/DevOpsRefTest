CREATE PROC [dbo].[usp_updateA1]
AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     10/05/15
Purpose     Updates A1 (all in one ticket) orders for use by [usp_ShippingLabels]
					and also by the A1 tab on the Intranet.
					This is called by job "i_A1_usp_ShippingLabels" which runs that sproc, which in turn runs this sproc, every 75s.
					Related proc for UPS:  [usp_ShippingLabels]
-------------------------------------------------------------------------------------
Modification History
09/08/16		updated to remove commercial from a1, jf.
09/08/16		updated to work only for HOM/NCC. Added WEB portion below, thus breaking this sproc into 2 pieces.
09/30/16		modified web portion, made life, jf.
11/01/16		modified near LN 54 regarding RDI, jf.
11/16/16		Changed tblAMZ_orderShip.a1_mailRate to tblAMZ_orderShip.a1_mailPieceShape, jf.
12/20/16		added R2P section at bottom of code, jf.
12/29/16		Added @GSC8; Added new Marketplace code. Old code resides in usp_updateA1_BAKJF_122916_priortoMarketplaceShift, jf.
01/04/17		updated initial query for Marketplace with correct ship-service-level code, jf.
03/02/17		Added UPS Marketplace conditions 172 thru 177, jf.
04/05/17		Added second subquery to R2P update to include UPSLabel check for R2P settings, jf.
04/13/17		THL - Sproc will check/set flag in tblUpdateA1flag to 1 when it's running (0 when it's not) so it won't interfere with itself; set back to 0 at the end of sproc
11/20/17		BJS - Update Temp table to true temp
10/26/18		Minor updates to qual'd joins, added expedite checks in initial query, jf.
10/26/18		Updated initial query to better performance; see backup of this sproc for reversion [usp_updateA1_BAK102618_01], jf.
10/30/18		Reverted the change to the intitial query but left it commented-out inline, for future A/B testing; see inline notes, jf.
03/22/19		JF, qual'd joins.
10/30/19		JF, happy halloween mofos. I had to rewrite the Amazon section because it was not qualifying A1's properly after we renamed thousands of products on Amazon. Fun!
04/15/20		JF, updated initial AMZ data retrieval to avoid pulling in signs on regular conditions.
04/28/20		JF, added condition 777; added initial query logic to bring in signs.
04/29/20		JF, had to add '% sign %' exclusion in the C24 and C72 sections b/c reports of USPS labels being gen'd for signage.
08/13/20		JF, added political signs to 777.
09/24/20		JF, KMN,  "AND [product-name] NOT LIKE '% Giant 24%'".
04/27/21		CKB, Markful
-------------------------------------------------------------------------------------
*/
SET NOCOUNT ON;
BEGIN TRY
	-- Check the flag in tblUpdateA1flag to see if this sproc is already running; Rollback if it is.
	DECLARE @flag INT
	SET @flag = (SELECT flag from tblUpdateA1flag)
	IF @flag = 1
		BEGIN 
			BEGIN TRAN
			ROLLBACK TRAN
		END
	ELSE
	UPDATE tblUpdateA1flag 
	SET flag = 1
	WHERE flag = 0

	--Declare and set GBS Shipping Class (GSC) variables to be referenced throughout sproc

	DECLARE 
		@GSC1_carrier VARCHAR(10),
		@GSC1_mailClass VARCHAR(50),
		@GSC1_mailPieceShape VARCHAR(50),
		@GSC2_carrier VARCHAR(10),
		@GSC2_mailClass VARCHAR(50),
		@GSC2_mailPieceShape VARCHAR(50),
		@GSC3_carrier VARCHAR(10),
		@GSC3_mailClass VARCHAR(50),
		@GSC3_mailPieceShape VARCHAR(50),
		@GSC4_carrier VARCHAR(10),
		@GSC4_mailClass VARCHAR(50),
		@GSC4_mailPieceShape VARCHAR(50),
		@GSC5_carrier VARCHAR(10),
		@GSC5_mailClass VARCHAR(50),
		@GSC5_mailPieceShape VARCHAR(50),
		@GSC6_carrier VARCHAR(10),
		@GSC6_mailClass VARCHAR(50),
		@GSC6_mailPieceShape VARCHAR(50),
		@GSC7_carrier VARCHAR(10),
		@GSC7_mailClass VARCHAR(50),
		@GSC7_mailPieceShape VARCHAR(50),
		@GSC8_carrier VARCHAR(10),
		@GSC8_mailClass VARCHAR(50),
		@GSC8_mailPieceShape VARCHAR(50)

	SET @GSC1_carrier = (SELECT carrier FROM tblA1_gbsShipClass WHERE gbsShipClass = 1)
	SET @GSC1_mailClass = (SELECT mailClass FROM tblA1_gbsShipClass WHERE gbsShipClass = 1)
	SET @GSC1_mailPieceShape = (SELECT mailPieceShape FROM tblA1_gbsShipClass WHERE gbsShipClass = 1)

	SET @GSC2_carrier = (SELECT carrier FROM tblA1_gbsShipClass WHERE gbsShipClass = 2)
	SET @GSC2_mailClass = (SELECT mailClass FROM tblA1_gbsShipClass WHERE gbsShipClass = 2)
	SET @GSC2_mailPieceShape = (SELECT mailPieceShape FROM tblA1_gbsShipClass WHERE gbsShipClass = 2)

	SET @GSC3_carrier = (SELECT carrier FROM tblA1_gbsShipClass WHERE gbsShipClass = 3)
	SET @GSC3_mailClass = (SELECT mailClass FROM tblA1_gbsShipClass WHERE gbsShipClass = 3)
	SET @GSC3_mailPieceShape = (SELECT mailPieceShape FROM tblA1_gbsShipClass WHERE gbsShipClass = 3)

	SET @GSC4_carrier = (SELECT carrier FROM tblA1_gbsShipClass WHERE gbsShipClass = 4)
	SET @GSC4_mailClass = (SELECT mailClass FROM tblA1_gbsShipClass WHERE gbsShipClass = 4)
	SET @GSC4_mailPieceShape = (SELECT mailPieceShape FROM tblA1_gbsShipClass WHERE gbsShipClass = 4)

	SET @GSC5_carrier = (SELECT carrier FROM tblA1_gbsShipClass WHERE gbsShipClass = 5)
	SET @GSC5_mailClass = (SELECT mailClass FROM tblA1_gbsShipClass WHERE gbsShipClass = 5)
	SET @GSC5_mailPieceShape = (SELECT mailPieceShape FROM tblA1_gbsShipClass WHERE gbsShipClass = 5)

	SET @GSC6_carrier = (SELECT carrier FROM tblA1_gbsShipClass WHERE gbsShipClass = 6)
	SET @GSC6_mailClass = (SELECT mailClass FROM tblA1_gbsShipClass WHERE gbsShipClass = 6)
	SET @GSC6_mailPieceShape = (SELECT mailPieceShape FROM tblA1_gbsShipClass WHERE gbsShipClass = 6)

	SET @GSC7_carrier = (SELECT carrier FROM tblA1_gbsShipClass WHERE gbsShipClass = 7)
	SET @GSC7_mailClass = (SELECT mailClass FROM tblA1_gbsShipClass WHERE gbsShipClass = 7)
	SET @GSC7_mailPieceShape = (SELECT mailPieceShape FROM tblA1_gbsShipClass WHERE gbsShipClass = 7)

	SET @GSC8_carrier = (SELECT carrier FROM tblA1_gbsShipClass WHERE gbsShipClass = 8)
	SET @GSC8_mailClass = (SELECT mailClass FROM tblA1_gbsShipClass WHERE gbsShipClass = 8)
	SET @GSC8_mailPieceShape = (SELECT mailPieceShape FROM tblA1_gbsShipClass WHERE gbsShipClass = 8)

	/*
	GSC1: | carrier: USPS | mailClass: First		 | mailPieceShape: Parcel
	GSC2: | carrier: USPS | mailClass: Priority	 | mailPieceShape: FlatRatePaddedEnvelope
	GSC3: | carrier: USPS | mailClass: Priority	 | mailPieceShape: RegionalRateBoxA
	GSC4: | carrier: USPS | mailClass: Priority	 | mailPieceShape: MediumFlatRateBox
	GSC5: | carrier: USPS | mailClass: Priority	 | mailPieceShape: RegionalRateBoxB
	GSC6: | carrier: USPS | mailClass: Priority	 | mailPieceShape: LargeFlatRateBox
	GSC7: | carrier:  UPS | mailClass: Ground		 | mailPieceShape: Box
	GSC8: | carrier:  UPS | mailClass: Ground		 | mailPieceShape: Cubic
	*/

	-------------------------------------------------------------------------------------
	--// 1. HOM/NCC
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	--refresh A1's in case of changes
	UPDATE tblOrders
	SET a1 = 1 --select count(orderid) from tblorders
	WHERE 
	a1 = 0
	AND orderID IN 
			(SELECT a.orderID
			FROM tblOrders a
			INNER JOIN tblCustomers c ON a.customerID = c.customerID
			INNER JOIN tblCustomers_ShippingAddress s ON a.orderNo = s.orderNo
			WHERE
			--orders with valid orderStatus.
			a.orderStatus NOT IN ('failed', 'cancelled', 'delivered', 'On HOM Dock', 'On MRK Dock', 'In Transit', 'In Transit USPS', 'MIGZ')

			--orders which have not already had an A1 label generated. this field is updated by label creation.
			AND a.orderJustPrinted = 0

			--orders with valid payment.
			AND a.displayPaymentStatus = 'Good'

			--orders that are not custom (performance v. redundancy)
			AND a.orderType <> 'Custom'

			--and RDI is residential "R". Changed from tblOrders.rescom on 11/1/16, jf.
			AND s.rdi = 'R'

			--orders that have qualifying A1 products within, at a product quantity of "1" for numUnits * productQuantity; can only have a SUM of "1" per order in this criteria.
			AND a.orderID IN
				(SELECT orderID
				FROM tblOrders_Products op
				INNER JOIN tblProducts pr ON op.productID = pr.productID
				WHERE op.deleteX <> 'yes'
				AND 
					--// Stock Cal Pad Mags
					(
						(pr.productType = 'Stock' AND pr.productName LIKE '%pad%' AND pr.productName LIKE '%calendar%')
						OR
						--// Stock QuickStix
						(pr.productType = 'Stock' AND pr.productName LIKE '%quickStix%' AND pr.productName NOT LIKE '%create%')
						OR
						--// Stock QuickStix
						(pr.productType = 'Stock' AND SUBSTRING(pr.productCode, 3, 2) = 'QS' AND pr.productName NOT LIKE '%create%')
						OR
						--// Stock QuickStix
						(pr.productType = 'Stock' AND SUBSTRING(pr.productCode, 1, 2) = 'QS' AND pr.productName NOT LIKE '%create%')
						OR
						--// Note Card Set (updated 2/17/16, jf; as per KH: "A1 tickets should include a single order of a 72 note card pak for the padded envelope rate")
						(pr.productType = 'Stock' AND pr.productName LIKE 'Note Card Set%')
					)
				GROUP BY orderID
				HAVING SUM(op.productQuantity * pr.numUnits) = 1
				)
	
			--order's shippingAddress has been validated.
			AND a.orderNo IN
				(SELECT orderNo
				FROM tblCustomers_ShippingAddress
				WHERE isValidated = 1)

			--orders that do not contain non-A1 products as shown above.
			AND a.orderID NOT IN
				(SELECT orderID
				FROM tblOrders_Products
				WHERE deleteX <> 'yes'
				AND productID NOT IN
						(SELECT productID 
						FROM tblProducts
						WHERE 
						--// Stock Cal Pad Mags
						(productType = 'Stock' AND productName LIKE '%pad%' AND productName LIKE '%calendar%' AND numUnits = 1)
						OR
						--// Stock QuickStix
						(productType = 'Stock' AND productName LIKE '%quickStix%' AND productName NOT LIKE '%create%' AND numUnits = 1)
						)
				)

			-- orders that do not have the "Production Timing: Complete Schedule (ship later)" product option selected.
			AND a.orderID NOT IN
				(SELECT orderID
				FROM tblOrders_Products
				WHERE deleteX <> 'yes'
				AND [ID] IN
					(SELECT ordersProductsID
					FROM tblOrdersProducts_productOptions
					WHERE deleteX <> 'yes'
					AND optionCaption = 'Complete Schedule (ship later)')
				)

			--orders that are not expedited.
			AND a.A1_expediteShipFlag <> 1
			)

	--/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	--// 2. WEB (Marketplace)
	/*
	Goal: To reduce shipping processing time we would like orders that meet a set of requirements to receive an All-In-One Ticket with a pre-paid shipping label. 

	Job Ticket Creation: 
		 All job tickets printed from the batch print option for Marketplace NEW orders should be formatted as an A1 ticket. 
		  Specs should follow the shipping label placement for current A1 tickets through HOM/NCC orders. 
		  Jobs that do not meet the requirements for a label should still be formatted to work on the A1 label stock, 
		  they would just have no label in the location on the ticket. The goal is to print ALL tickets on the same 
		  label stock paper as most of the orders will qualify and we would only have to have a single tab to print from. 
	*/

	--first, select all records that have an a1 value that is NULL. At the end of this code, if they haven't been assigned to "1", they'll go to "0". 
	TRUNCATE TABLE tblAMZ_tempA1X1
	INSERT INTO tblAMZ_tempA1X1 (orderNo)
	SELECT orderNo
	FROM tblAMZ_orderShip
	WHERE A1 IS NULL

	--refresh orderNos in table that houses orderNos that share common traits used across all conditionIDs
	--since a1 defaults to NULL, this is a good indicator of an orderNo that has not undergone this process
	TRUNCATE TABLE tblA1_MP
	INSERT INTO tblA1_MP (orderNo)
	SELECT TOP 1000 orderNo
	FROM tblAMZ_orderShip
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		WHERE ((	[product-name] LIKE '%Card%' 
					AND [product-name] NOT LIKE '% Sign%'
					AND ([product-name] LIKE '%24%' 
						OR [product-name] LIKE '%72%'))
				OR SKU LIKE 'YSHL%'
				OR SKU LIKE 'YSCVD%'
				OR SKU LIKE 'YSGRD%'
				OR SKU LIKE 'YSALH%'
				)
		AND [ship-service-level] = 'Standard'
		)
	AND isValidated = 1
	AND a1_processed = 0
	AND (a1 IS NULL
		 OR a1 = 0)
	AND (returnCode = 31 OR returnCode = 32)
	AND CONVERT(INT,(SUBSTRING(orderNo, 4, 6))) > 239106
	ORDER BY orderNo_ID DESC

	--update common shipping-related values for each orderNo used in A1 condition assignments
	UPDATE a
	SET shipState = b.[ship-state]
	FROM tblA1_MP a
	INNER JOIN tblAMZ_orderShip b ON a.orderNo = b.orderNo

	UPDATE a
	SET GBSZone = b.GBSZone
	FROM tblA1_MP a
	INNER JOIN tblAMZ_orderShip s ON a.orderNo = s.orderNo
	INNER JOIN tblZone b ON SUBSTRING(s.[ship-postal-code], 1, 3) = b.zip

	UPDATE a
	SET rdi = b.rdi
	FROM tblA1_MP a
	INNER JOIN tblAMZ_orderShip b ON a.orderNo = b.orderNo
	WHERE b.rdi IS NOT NULL

	UPDATE a
	SET UPSRural = b.UPSRural
	FROM tblA1_MP a
	INNER JOIN tblAMZ_orderShip b ON a.orderNo = b.orderNo
	WHERE b.UPSRural IS NOT NULL

	UPDATE a
	SET returnCode = b.returnCode
	FROM tblA1_MP a
	INNER JOIN tblAMZ_orderShip b ON a.orderNo = b.orderNo
	WHERE b.returnCode IS NOT NULL

	--update bit values that determine existence of certain product w/in order.
	UPDATE tblA1_MP
	SET C24 = 1
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		WHERE [product-name] LIKE '%24%' AND [product-name] LIKE '%card%' AND [product-name] NOT LIKE '% Sign %' AND [product-name] NOT LIKE '% Giant 24%')

	UPDATE tblA1_MP
	SET C72 = 1
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		WHERE [product-name] LIKE '%72%' AND [product-name] LIKE '%card%' AND [product-name] NOT LIKE '% Sign %' AND [product-name] NOT LIKE '% Giant 24%')

	--update amalgamated QTY values for products defined above
	IF OBJECT_ID('tempdb..#tempPSU_A1MP') IS NOT NULL
	DROP TABLE #tempPSU_A1MP


	CREATE TABLE #tempPSU_A1MP 
					(RowID INT IDENTITY(1, 1), 
					 orderNo VARCHAR(50))

	DECLARE @NumberRecords INT, 
			  @RowCount INT,
			  @orderNo VARCHAR(50), 
			  @C24_QTY INT,
			  @C72_QTY INT

	INSERT INTO #tempPSU_A1MP (orderNo)
	SELECT DISTINCT(orderNo)
	FROM tblA1_MP

	SET @NumberRecords = @@ROWCOUNT
	SET @RowCount = 1

	WHILE @RowCount <= @NumberRecords
		BEGIN
			SELECT @orderNo = orderNo
			FROM #tempPSU_A1MP
			WHERE RowID = @RowCount

			--C24
			SET @C24_QTY = 0
			SET @C24_QTY = (SELECT SUM(CONVERT(INT, ([quantity-purchased])))
									FROM tblAMZ_orderValid
									WHERE ([product-name] LIKE '%24%' AND [product-name] LIKE '%card%' AND [product-name] NOT LIKE '% Giant 24%')
									AND orderNo = @orderNo)

			IF @C24_QTY IS NULL
			BEGIN
				SET @C24_QTY = 0
			END

			--C72
			SET @C72_QTY = 0
			SET @C72_QTY = (SELECT SUM(CONVERT(INT, ([quantity-purchased])))
									FROM tblAMZ_orderValid
									WHERE [product-name] LIKE '%72%' AND [product-name] LIKE '%card%' 
									AND orderNo = @orderNo)

			IF @C72_QTY IS NULL
			BEGIN
				SET @C72_QTY = 0
			END

			--Set all values assigned above
			UPDATE tblA1_MP
			SET C24_QTY = @C24_QTY,
				 C72_QTY = @C72_QTY
			WHERE orderNo = @orderNo

			--Grab SUM(QTY) for everything targeted for the given @orderNo
			UPDATE tblA1_MP
			SET cnAll_Targeted = @C24_QTY + @C72_QTY
			WHERE orderNo = @orderNo

			--Set OPID counts of products within order that are NOT the productCode(s) in question.
				
			--cnC24
			UPDATE tblA1_MP
			SET cnC24 = (SELECT COUNT(DISTINCT(ID))
							  FROM tblAMZ_orderValid
							  WHERE [product-name] NOT LIKE '%24%'
							  AND orderNo = @orderNo)
			WHERE C24 = 1
			AND orderNo = @orderNo

			--cnC72
			UPDATE tblA1_MP
			SET cnC72 = (SELECT COUNT(DISTINCT(ID))
							  FROM tblAMZ_orderValid
							  WHERE [product-name] NOT LIKE '%72%'
							  AND orderNo = @orderNo)
			WHERE C72 = 1
			AND orderNo = @orderNo

			--cnC24_C72
			UPDATE tblA1_MP
			SET cnC24_C72 = (SELECT COUNT(DISTINCT(ID))
								  FROM tblAMZ_orderValid
								  WHERE [product-name] NOT LIKE '%24%'
								  AND [product-name] NOT LIKE '%72%'
								  AND orderNo = @orderNo)
			WHERE C24 = 1
			AND C72 = 1
			AND orderNo = @orderNo

			SET @RowCount = @RowCount + 1
		END

	IF OBJECT_ID('tempdb..#tempPSU_A1MP') IS NOT NULL
	DROP TABLE #tempPSU_A1MP

	UPDATE tblA1_MP SET cnC24 = 0 WHERE cnC24 IS NULL
	UPDATE tblA1_MP SET cnC72 = 0 WHERE cnC72 IS NULL
	UPDATE tblA1_MP SET cnC24_C72 = 0 WHERE cnC24_C72 IS NULL
	
	declare @tblAMZ_orderShip_Update table 
	([order-id] nvarchar(255), a1 bit, a1_conditionID int, a1_mailPieceShape nvarchar(50), a1_mailClass nvarchar(50), a1_carrier nvarchar(50))

	-- conditionID = 1 / gbsShipClass = 1 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 1,
		 a1_mailPieceShape = @GSC1_mailPieceShape,
		 a1_mailClass = @GSC1_mailClass,
		 a1_carrier = @GSC1_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C24 = 1
		AND C24_QTY = 1
		AND cnC24 = 0)

	-- conditionID = 2 / gbsShipClass = 2 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 2,
		 a1_mailPieceShape = @GSC2_mailPieceShape,
		 a1_mailClass = @GSC2_mailClass,
		 a1_carrier = @GSC2_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C24 = 1
		AND C24_QTY BETWEEN 2 AND 4
		AND cnC24 = 0
		AND RDI = 'R')

	-- conditionID = 3 / gbsShipClass = 2 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 3,
		 a1_mailPieceShape = @GSC2_mailPieceShape,
		 a1_mailClass = @GSC2_mailClass,
		 a1_carrier = @GSC2_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C24 = 1
		AND C24_QTY BETWEEN 2 AND 4
		AND cnC24 = 0
		AND RDI = 'B'
		AND UPSRural = 1)

	-- conditionID = 4 / gbsShipClass = 2 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 4,
		 a1_mailPieceShape = @GSC2_mailPieceShape,
		 a1_mailClass = @GSC2_mailClass,
		 a1_carrier = @GSC2_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C72 = 1
		AND C72_QTY = 1
		AND cnC72 = 0
		AND RDI = 'R')

	-- conditionID = 5 / gbsShipClass = 2 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 5,
		 a1_mailPieceShape = @GSC2_mailPieceShape,
		 a1_mailClass = @GSC2_mailClass,
		 a1_carrier = @GSC2_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C72 = 1
		AND C72_QTY = 1
		AND cnC72 = 0
		AND RDI = 'B'
		AND UPSRural = 1)

	-- conditionID = 6 / gbsShipClass = 2 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 6,
		 a1_mailPieceShape = @GSC2_mailPieceShape,
		 a1_mailClass = @GSC2_mailClass,
		 a1_carrier = @GSC2_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C72 = 1
		AND C72_QTY = 1
		AND C24 = 1
		AND C24_QTY = 1
		AND cnC24_C72 = 0
		AND RDI = 'R')

	-- conditionID = 7 / gbsShipClass = 2 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 7,
		 a1_mailPieceShape = @GSC2_mailPieceShape,
		 a1_mailClass = @GSC2_mailClass,
		 a1_carrier = @GSC2_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C72 = 1
		AND C72_QTY = 1
		AND C24 = 1
		AND C24_QTY = 1
		AND cnC24_C72 = 0
		AND RDI = 'B'
		AND UPSRural = 1)

	-- conditionID = 8 / gbsShipClass = 3 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 8,
		 a1_mailPieceShape = @GSC3_mailPieceShape,
		 a1_mailClass = @GSC3_mailClass,
		 a1_carrier = @GSC3_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C72 = 1
		AND C72_QTY = 2
		AND cnC72 = 0
		AND RDI = 'R'
		AND GBSZone BETWEEN 2 AND 4)

	-- conditionID = 9 / gbsShipClass = 3 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 9,
		 a1_mailPieceShape = @GSC3_mailPieceShape,
		 a1_mailClass = @GSC3_mailClass,
		 a1_carrier = @GSC3_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C72 = 1
		AND C72_QTY = 2
		AND C24 = 1
		AND C24_QTY = 1
		AND cnC24_C72 = 0
		AND RDI = 'R'
		AND GBSZone BETWEEN 2 AND 4)
	
	-- conditionID = 10 / gbsShipClass = 3 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 10,
		 a1_mailPieceShape = @GSC3_mailPieceShape,
		 a1_mailClass = @GSC3_mailClass,
		 a1_carrier = @GSC3_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C72 = 1
		AND C72_QTY = 1
		AND C24 = 1
		AND C24_QTY BETWEEN 2 AND 4
		AND cnC24_C72 = 0
		AND RDI = 'R'
		AND GBSZone BETWEEN 2 AND 4)

	-- conditionID = 11 / gbsShipClass = 3 --------------------------------------------------
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 11,
		 a1_mailPieceShape = @GSC3_mailPieceShape,
		 a1_mailClass = @GSC3_mailClass,
		 a1_carrier = @GSC3_carrier
	from tblAMZ_orderShip a
	WHERE orderNo IN
		(SELECT orderNo
		FROM tblA1_MP
		WHERE C24 = 1
		AND C24_QTY BETWEEN 5 AND 7
		AND cnC24 = 0
		AND RDI = 'R'
		AND GBSZone BETWEEN 2 AND 4)

--//////////////////////////////////////////////////////////////////////////////////////////////////////
	--// MARKETPLACE UPS ADDITIONS BEGIN HERE. 4/28/2020
	-- conditionID = 172 / gbsShipClass = 7 -------------------------------------------------- UPS
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 172,
		 a1_mailPieceShape = @GSC7_mailPieceShape,
		 a1_mailClass = @GSC7_mailClass,
		 a1_carrier = @GSC7_carrier
	from tblAMZ_orderShip a
	where exists 
		(select top 1 1 from tblAMZ_orderValid aov where a.orderNo = aov.orderNo 
		and ([product-name] LIKE '%24%' AND [product-name] LIKE '%card%' AND [product-name] NOT LIKE '% Giant 24%')
		AND [quantity-purchased] >= 2
		AND [quantity-purchased] <= 4
		AND [ship-service-level] = 'Standard')
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		GROUP BY orderNo
		HAVING COUNT(orderNo) = 1)
	AND rdi = 'B'
	AND isValidated = 1
	AND a1 = 0
	AND a1_processed = 0
	AND a1_printed = 0
	AND (returnCode = 31 OR returnCode = 32)

	-- conditionID = 173 / gbsShipClass = 7 -------------------------------------------------- UPS
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 173,
		 a1_mailPieceShape = @GSC7_mailPieceShape,
		 a1_mailClass = @GSC7_mailClass,
		 a1_carrier = @GSC7_carrier
	from tblAMZ_orderShip a
	where exists 
		(select top 1 1 from tblAMZ_orderValid aov where a.orderNo = aov.orderNo 
		and ([product-name] LIKE '%24%' AND [product-name] LIKE '%card%' AND [product-name] NOT LIKE '% Giant 24%')
		AND [quantity-purchased] IN (2, 3, 4)
		AND [ship-service-level] = 'Standard')
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		GROUP BY orderNo
		HAVING COUNT(orderNo) = 1)
	AND rdi = 'B'
	AND UPSRural = 0
	AND isValidated = 1
	AND a1 = 0
	AND a1_processed = 0
	AND a1_printed = 0
	AND (returnCode = 31 OR returnCode = 32)

	-- conditionID = 174 / gbsShipClass = 7 -------------------------------------------------- UPS
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 174,
		 a1_mailPieceShape = @GSC7_mailPieceShape,
		 a1_mailClass = @GSC7_mailClass,
		 a1_carrier = @GSC7_carrier
	from tblAMZ_orderShip a
	where exists 
		(select top 1 1 from tblAMZ_orderValid aov where a.orderNo = aov.orderNo 
		and [product-name] LIKE '%72%' AND [product-name] LIKE '%card%'
		AND [quantity-purchased] = 1
		AND [ship-service-level] = 'Standard')
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		GROUP BY orderNo
		HAVING COUNT(orderNo) = 1)
	AND rdi = 'B'
	AND isValidated = 1
	AND a1 = 0
	AND a1_processed = 0
	AND a1_printed = 0
	AND (returnCode = 31 OR returnCode = 32)

	-- conditionID = 175 / gbsShipClass = 7 -------------------------------------------------- UPS
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 175,
		 a1_mailPieceShape = @GSC7_mailPieceShape,
		 a1_mailClass = @GSC7_mailClass,
		 a1_carrier = @GSC7_carrier
	from tblAMZ_orderShip a
	where exists 
		(select top 1 1 from tblAMZ_orderValid aov where a.orderNo = aov.orderNo 
		and [product-name] LIKE '%72%' AND [product-name] LIKE '%card%'
		AND [quantity-purchased] = 1
		AND [ship-service-level] = 'Standard')
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		GROUP BY orderNo
		HAVING COUNT(orderNo) = 1)
	AND rdi = 'B'
	AND UPSRural = 0
	AND isValidated = 1
	AND a1 = 0
	AND a1_processed = 0
	AND a1_printed = 0
	AND (returnCode = 31 OR returnCode = 32)

	-- conditionID = 176 / gbsShipClass = 7 -------------------------------------------------- UPS
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 176,
		 a1_mailPieceShape = @GSC7_mailPieceShape,
		 a1_mailClass = @GSC7_mailClass,
		 a1_carrier = @GSC7_carrier
	from tblAMZ_orderShip a
	where exists 
		(select top 1 1 from tblAMZ_orderValid aov where a.orderNo = aov.orderNo 
		and [product-name] LIKE '%72%' AND [product-name] LIKE '%card%'
		AND [quantity-purchased] = 1
		AND [ship-service-level] = 'Standard')
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		WHERE ([product-name] LIKE '%24%' AND [product-name] LIKE '%card%' AND [product-name] NOT LIKE '% Giant 24%')
		AND [quantity-purchased] = 1
		AND [ship-service-level] = 'Standard')
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		GROUP BY orderNo
		HAVING COUNT(orderNo) = 2)
	AND rdi = 'B'
	AND isValidated = 1
	AND a1 = 0
	AND a1_processed = 0
	AND a1_printed = 0
	AND (returnCode = 31 OR returnCode = 32)

	-- conditionID = 177 / gbsShipClass = 7 -------------------------------------------------- UPS
	insert into @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	select a.[order-id], a1 = 1, a1_conditionID = 177,
		 a1_mailPieceShape = @GSC7_mailPieceShape,
		 a1_mailClass = @GSC7_mailClass,
		 a1_carrier = @GSC7_carrier
	from tblAMZ_orderShip a
	where exists 
		(select top 1 1 from tblAMZ_orderValid aov where a.orderNo = aov.orderNo 
		and [product-name] LIKE '%72%' AND [product-name] LIKE '%card%'
		AND [quantity-purchased] = 1
		AND [ship-service-level] = 'Standard')
	and exists
		(select top 1 1 from tblAMZ_orderValid aov where a.orderNo = aov.orderNo 
		and ([product-name] LIKE '%24%' AND [product-name] LIKE '%card%' AND [product-name] NOT LIKE '% Giant 24%')
		AND [quantity-purchased] = 1
		AND [ship-service-level] = 'Standard')
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		GROUP BY orderNo
		HAVING COUNT(orderNo) = 2)
	AND rdi = 'B'
	AND UPSRural = 0
	AND isValidated = 1
	AND a1 = 0
	AND a1_processed = 0
	AND a1_printed = 0
	AND (returnCode = 31 OR returnCode = 32)

	-- conditionID = 777 / gbsShipClass = 7 -------------------------------------------------- UPS (SIGNS)
	INSERT INTO @tblAMZ_orderShip_Update
	([order-id], a1, a1_conditionID, a1_mailPieceShape, a1_mailClass, a1_carrier)
	SELECT a.[order-id], a1 = 1, a1_conditionID = 777,
		 a1_mailPieceShape = @GSC7_mailPieceShape,
		 a1_mailClass = @GSC7_mailClass,
		 a1_carrier = @GSC7_carrier
	FROM tblAMZ_orderShip a
	WHERE EXISTS 
		(SELECT TOP 1 1 
		FROM tblAMZ_orderValid aov 
		WHERE a.orderNo = aov.orderNo 
		AND (SUBSTRING(SKU, 1, 4) IN ('YSHL', 'YSCV', 'YSGR', 'YSAL')
				OR SUBSTRING(SKU, 1, 5) IN ('YSPOL'))
		AND [quantity-purchased] = 1
		AND [ship-service-level] = 'Standard') --only 1 sign with the SKU prefixes above
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_orderValid
		GROUP BY orderNo
		HAVING COUNT(orderNo) = 1) --no other products ride with the sign
	AND isValidated = 1
	AND a1 = 0
	AND a1_processed = 0
	AND a1_printed = 0

	UPDATE a
	SET a1 = au.a1, A1_conditionID = au.a1_conditionID, A1_mailPieceShape = au.a1_mailPieceShape, 
	A1_mailClass = au.a1_mailClass, A1_carrier = au.a1_carrier
	FROM tblAMZ_orderShip a
	INNER JOIN @tblAMZ_orderShip_Update au ON a.[order-id] = au.[order-id]

	--// MARKETPLACE UPS ADDITIONS END HERE.

	--//////////////////////////////////////////////////////////////////////////////////////////////////////
	--// Update R2P values for A1 orders that have successfully had a label gen'd (which by default, means they've undergone valCheck).
	UPDATE tblAMZ_orderShip
	SET R2P = 1
	WHERE R2P = 0
	AND a1 = 1
	AND (orderNo IN
			(SELECT referenceID
			FROM tblShippingLabels
			WHERE getLabel = 1)
		OR
		orderNo IN
			(SELECT orderNo
			FROM tblUPSLabel
			WHERE labelGenerated = 1))

	--// Update R2P values for X1 orders. No label gen needed, however valCheck is still required.
	UPDATE tblAMZ_orderShip
	SET R2P = 1
	WHERE R2P = 0
	AND a1 = 0
	AND isValidated IS NOT NULL

	--lastly, all records that have an a1 value that was NULL at the beginning of this section and has not been assigned to "1", will go to "0".
	UPDATE tblAMZ_orderShip
	SET A1 = 0
	WHERE A1 IS NULL
	AND orderNo IN
		(SELECT orderNo
		FROM tblAMZ_tempA1X1)

	-- timestamp successful run
	UPDATE tblA1_lastRun
	SET a1_lastRun = GETDATE()

	-- THL - 04132017 - Update flag on tblUpdateA1flag to 0 to represent the Stored Procedure has finished running
	UPDATE tblUpdateA1flag
	SET flag = 0
	where flag = 1
END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH