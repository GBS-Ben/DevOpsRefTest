CREATE PROC [dbo].[usp_updateA1_test]
AS
-------------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     10/05/15
-- Purpose     Updates A1 (all in one ticket) orders for use by [usp_ShippingLabels]
--					and also by the A1 tab on the Intranet.
--					This is called by job "i_A1_usp_ShippingLabels" which runs that sproc, which in turn runs this sproc, every 75s.
--					To reduce shipping processing time we would like orders that meet a set of requirements to receive an All-In-One Ticket with a pre-paid shipping label. 
/*
	Job Ticket Creation: 
		  All job tickets printed from the batch print option for Marketplace NEW orders should be formatted as an A1 ticket. 
		  Specs should follow the shipping label placement for current A1 tickets through HOM/NCC orders. 
		  Jobs that do not meet the requirements for a label should still be formatted to work on the A1 label stock, 
		  they would just have no label in the location on the ticket. The goal is to print ALL tickets on the same 
		  label stock paper as most of the orders will qualify and we would only have to have a single tab to print from. 
*/
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- Modification History
--	09/8/16		updated to remove commercial from a1; jf.
-- 09/8/16		updated to work only for HOM/NCC. Added WEB portion below, thus
--					breaking this sproc into 2 pieces.
-- 09/30/16		modified web portion, made life; jf.
-- 11/1/16		modified near LN 54 regarding RDI; jf.
-- 11/16/16		Changed tblAMZ_orderShip.a1_mailRate to tblAMZ_orderShip.a1_mailPieceShape; jf.
-- 11/30/16		Overhaul of HOM/NCC portion of A1; jf.
-- 04/27/21		CKB, Markful
-------------------------------------------------------------------------------------

--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--// 1. HOM/NCC
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////

--refresh A1's in case of changes
UPDATE tblOrders
SET a1 = 0
WHERE a1 = 1
AND orderStatus NOT IN ('failed', 'cancelled', 'delivered', 'On HOM Dock', 'On MRK Dock', 'In Transit', 'In Transit USPS', 'MIGZ')

----//start test here: ~~~~~~~~~~~
--		--test
--		UPDATE tblOrders
--		SET a1 = 0,
--			 a1_conditionID = NULL
--		WHERE orderNo = 'HOM570088'

--refresh orderNos in table that houses orderNos that share common traits used across all conditionIDs
TRUNCATE TABLE tblA1_CC
INSERT INTO tblA1_CC (orderID, orderNo)
SELECT TOP 250 orderID, orderNo
FROM tblOrders
WHERE orderStatus NOT IN ('failed', 'cancelled', 'delivered', 'On HOM Dock', 'On MRK Dock', 'In Transit', 'In Transit USPS', 'MIGZ')
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND a1_expediteShipFlag = 0
AND orderType <> 'Custom'
AND displayPaymentStatus = 'Good'
AND orderNo IN
	(SELECT orderNo
	FROM tblCustomers_ShippingAddress
	WHERE isValidated = 1
	AND (returnCode = 31 
	     OR returnCode = 32))
AND orderID NOT IN
	(SELECT orderID
	FROM tblOrders_Products
	WHERE deleteX <> 'yes'
	AND [ID] IN
		(SELECT ordersProductsID
		FROM tblOrdersProducts_productOptions
		WHERE deleteX <> 'yes'
		AND optionCaption = 'Complete Schedule (ship later)'))
--AND orderNo = 'HOM570088'

--update common shipping-related values for each orderNo used in A1 condition assignments
UPDATE tblA1_CC
SET shipState = b.Shipping_State
FROM tblA1_CC a
JOIN tblCustomers_ShippingAddress b
	ON a.orderNo = b.orderNo

UPDATE tblA1_CC
SET GBSZone = b.GBSZone
FROM tblA1_CC a
JOIN tblCustomers_ShippingAddress s
	ON a.orderNo = s.orderNo
JOIN tblZone b
	ON SUBSTRING(s.Shipping_PostCode, 1, 3) = b.zip

UPDATE tblA1_CC
SET rdi = b.rdi
FROM tblA1_CC a
JOIN tblCustomers_ShippingAddress b
	ON a.orderNo = b.orderNo
WHERE b.rdi IS NOT NULL

UPDATE tblA1_CC
SET UPSRural = b.UPSRural
FROM tblA1_CC a
JOIN tblCustomers_ShippingAddress b
	ON a.orderNo = b.orderNo
WHERE b.UPSRural IS NOT NULL

UPDATE tblA1_CC
SET returnCode = b.returnCode
FROM tblA1_CC a
JOIN tblCustomers_ShippingAddress b
	ON a.orderNo = b.orderNo
WHERE b.returnCode IS NOT NULL

--update bit values that determine existence of certain product w/in order.
UPDATE tblA1_CC
SET CACP = 1
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders_Products op
	JOIN tblProducts p
		ON op.productID = p.productID
	WHERE op.productCode LIKE 'CACP%'
	AND op.deleteX <> 'yes')

UPDATE tblA1_CC
SET DK = 1
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders_Products op
	JOIN tblProducts p
		ON op.productID = p.productID
	WHERE op.productCode LIKE 'DK%'
	AND op.deleteX <> 'yes')

UPDATE tblA1_CC
SET ES = 1
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders_Products op
	JOIN tblProducts p
		ON op.productID = p.productID
	WHERE op.productCode LIKE 'ES%'
	AND p.productID NOT IN ('8039', '8040', '8041')
	AND op.deleteX <> 'yes')

UPDATE tblA1_CC
SET QS = 1
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders_Products op
	JOIN tblProducts p
		ON op.productID = p.productID
	WHERE SUBSTRING(op.productCode, 3, 2) = 'QS'
	AND p.productType = 'Stock'
	AND op.deleteX <> 'yes')

UPDATE tblA1_CC
SET EV07 = 1
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders_Products op
	JOIN tblProducts p
		ON op.productID = p.productID
	WHERE op.productCode LIKE 'EV%'
	AND SUBSTRING(op.productCode, 5, 2) = '07'
	AND op.deleteX <> 'yes')

UPDATE tblA1_CC
SET EV10 = 1
WHERE orderID IN
	(SELECT orderID
	FROM tblOrders_Products op
	JOIN tblProducts p
		ON op.productID = p.productID
	WHERE op.productCode LIKE 'EV%'
	AND SUBSTRING(op.productCode, 5, 2) = '10'
	AND op.deleteX <> 'yes')

--update amalgamated QTY values for products defined above
IF OBJECT_ID(N'tempPSU_A1CC', N'U') IS NOT NULL 
DROP TABLE tempPSU_A1CC

CREATE TABLE tempPSU_A1CC 
				(RowID INT IDENTITY(1, 1), 
				 orderID INT)

DECLARE @NumberRecords INT, 
		  @RowCount INT,
		  @orderID INT, 
		  @CACP_QTY INT,
		  @DK_QTY INT,
		  @ES_QTY INT,
		  @QS_QTY INT,
		  @EV07_QTY INT,
		  @EV10_QTY INT

INSERT INTO tempPSU_A1CC (orderID)
SELECT DISTINCT(orderID)
FROM tblA1_CC

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
	BEGIN
		SELECT @orderID = orderID
		FROM tempPSU_A1CC
		WHERE RowID = @RowCount

		--CACP
		SET @CACP_QTY = 0
		SET @CACP_QTY = (SELECT SUM(productQuantity)
								FROM tblOrders_Products
								WHERE productCode LIKE 'CACP%'
								AND deleteX <> 'yes'
								AND orderID = @orderID)

		IF @CACP_QTY IS NULL
		BEGIN
			SET @CACP_QTY = 0
		END

		--DK
		SET @DK_QTY = 0
		SET @DK_QTY = (SELECT SUM(productQuantity)
							FROM tblOrders_Products
							WHERE productCode LIKE 'DK%'
							AND deleteX <> 'yes'
							AND orderID = @orderID)

		IF @DK_QTY IS NULL
		BEGIN
			SET @DK_QTY = 0
		END

		--ES
		SET @ES_QTY = 0
		SET @ES_QTY = (SELECT SUM(productQuantity)
							FROM tblOrders_Products op
							JOIN tblProducts p
								ON op.productID = p.productID
							WHERE op.productCode LIKE 'ES%'
							AND op.deleteX <> 'yes'
							AND p.productID NOT IN ('8039', '8040', '8041')
							AND op.orderID = @orderID)

		IF @ES_QTY IS NULL
		BEGIN
			SET @ES_QTY = 0
		END

		--QS_
		SET @QS_QTY = 0
		SET @QS_QTY = (SELECT SUM(productQuantity)
									FROM tblOrders_Products op
									JOIN tblProducts p
										ON op.productID = p.productID
									WHERE SUBSTRING(op.productCode, 3, 2) = 'QS'
									AND p.productType = 'Stock'
									AND op.deleteX <> 'yes'
									AND op.orderID = @orderID)

		IF @QS_QTY IS NULL
		BEGIN
			SET @QS_QTY = 0
		END

		--EV07
		SET @EV07_QTY = 0
		SET @EV07_QTY = (SELECT SUM(productQuantity)
								FROM tblOrders_Products op
								JOIN tblProducts p
									ON op.productID = p.productID
								WHERE op.productCode LIKE 'EV%'
								AND SUBSTRING(op.productCode, 5, 2) = '07'
								AND op.deleteX <> 'yes'
								AND op.orderID = @orderID)

		IF @EV07_QTY IS NULL
		BEGIN
			SET @EV07_QTY = 0
		END

		--EV10
		SET @EV10_QTY = 0
		SET @EV10_QTY = (SELECT SUM(productQuantity)
								FROM tblOrders_Products op
								JOIN tblProducts p
									ON op.productID = p.productID
								WHERE op.productCode LIKE 'EV%'
								AND SUBSTRING(op.productCode, 5, 2) = '10'
								AND op.deleteX <> 'yes'
								AND op.orderID = @orderID)

		IF @EV10_QTY IS NULL
		BEGIN
			SET @EV10_QTY = 0
		END

		--Set all values assigned above
		UPDATE tblA1_CC
		SET CACP_QTY = @CACP_QTY,
			 DK_QTY = @DK_QTY,
			 ES_QTY = @ES_QTY,
			 QS_QTY = @QS_QTY,
			 EV07_QTY = @EV07_QTY,
			 EV10_QTY = @EV10_QTY
		WHERE orderID = @orderID

		--Grab SUM(QTY) for everything targeted for the given @orderID
		UPDATE tblA1_CC
		SET cnAll_Targeted = @CACP_QTY + @DK_QTY + @ES_QTY + @QS_QTY + @EV07_QTY + @EV10_QTY
		WHERE orderID = @orderID

		--Set OPID counts of products within order besides productCode(s) in question.
				
		--cnCACP
		UPDATE tblA1_CC
		SET cnCACP = (SELECT COUNT(DISTINCT(ID))
						  FROM tblOrders_Products
						  WHERE productCode NOT LIKE 'CACP%'
						  AND deleteX <> 'yes'
						  AND orderID = @orderID)
		WHERE CACP = 1
		AND orderID = @orderID

		--cnCACP_DK
		UPDATE tblA1_CC
		SET cnCACP_DK = (SELECT COUNT(DISTINCT(ID))
							  FROM tblOrders_Products
							  WHERE productCode NOT LIKE 'CACP%'
							  AND productCode NOT LIKE 'DK%'
							  AND deleteX <> 'yes'
							  AND orderID = @orderID)
		WHERE CACP = 1
		AND DK = 1
		AND orderID = @orderID

		--cnCACP_ES
		UPDATE tblA1_CC
		SET cnCACP_ES = (SELECT COUNT(DISTINCT(ID))
							  FROM tblOrders_Products
							  WHERE productCode NOT LIKE 'CACP%'
							  AND productCode NOT IN
									(SELECT productCode
									FROM tblProducts
									WHERE productCode LIKE 'ES%'
									AND productID NOT IN ('8039', '8040', '8041'))
							  AND deleteX <> 'yes'
							  AND orderID = @orderID)
		WHERE CACP = 1
		AND ES = 1
		AND orderID = @orderID

		--cnCACP_DK_ES
		UPDATE tblA1_CC
		SET cnCACP_DK_ES = (SELECT COUNT(DISTINCT(ID))
								  FROM tblOrders_Products
								  WHERE productCode NOT LIKE 'CACP%'
								  AND productCode NOT LIKE 'DK%'
								  AND productCode NOT IN
										(SELECT productCode
										FROM tblProducts
										WHERE productCode LIKE 'ES%'
										AND productID NOT IN ('8039', '8040', '8041'))
								  AND deleteX <> 'yes'
								  AND orderID = @orderID)
		WHERE CACP = 1
		AND DK = 1
		AND ES = 1
		AND orderID = @orderID

		--cnCACP_EV07
		UPDATE tblA1_CC
		SET cnCACP_EV07 = (SELECT COUNT(DISTINCT(ID))
								  FROM tblOrders_Products
								  WHERE productCode NOT LIKE 'CACP%'
								  AND productCode NOT IN
										(SELECT productCode
										FROM tblProducts
										WHERE productCode LIKE 'EV%'
										AND (SUBSTRING(productCode, 5, 2) = '07'))
								  AND deleteX <> 'yes'
								  AND orderID = @orderID)
		WHERE CACP = 1
		AND EV07 = 1
		AND orderID = @orderID

		--cnCACP_EV07_DK
		UPDATE tblA1_CC
		SET cnCACP_EV07_DK = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT LIKE 'CACP%'
									  AND productCode NOT LIKE 'DK%'
									  AND productCode NOT IN
											(SELECT productCode
											FROM tblProducts
											WHERE productCode LIKE 'EV%'
											AND (SUBSTRING(productCode, 5, 2) = '07'))
									  AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE CACP = 1
		AND DK = 1
		AND EV07 = 1
		AND orderID = @orderID

		--cnCACP_EV07_ES
		UPDATE tblA1_CC
		SET cnCACP_EV07_ES = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT LIKE 'CACP%'
									  AND productCode NOT IN
											(SELECT productCode
											FROM tblProducts
											WHERE (productCode LIKE 'EV%'
													AND (SUBSTRING(productCode, 5, 2) = '07'))
											OR		(productCode LIKE 'ES%'
													AND productID NOT IN ('8039', '8040', '8041')))
									  AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE CACP = 1
		AND ES = 1
		AND EV07 = 1
		AND orderID = @orderID

		--cnCACP_EV07_DK_ES
		UPDATE tblA1_CC
		SET cnCACP_EV07_DK_ES = (SELECT COUNT(DISTINCT(ID))
										  FROM tblOrders_Products
										  WHERE productCode NOT LIKE 'CACP%'
										  AND productCode NOT LIKE 'DK%'
										  AND productCode NOT IN
												(SELECT productCode
												FROM tblProducts
												WHERE (productCode LIKE 'EV%'
														AND (SUBSTRING(productCode, 5, 2) = '07'))
												OR		(productCode LIKE 'ES%'
														AND productID NOT IN ('8039', '8040', '8041')))
										  AND deleteX <> 'yes'
										  AND orderID = @orderID)
		WHERE CACP = 1
		AND DK = 1
		AND ES = 1
		AND EV07 = 1
		AND orderID = @orderID

		--cnCACP_EV10
		UPDATE tblA1_CC
		SET cnCACP_EV10 = (SELECT COUNT(DISTINCT(ID))
								  FROM tblOrders_Products
								  WHERE productCode NOT LIKE 'CACP%'
								  AND productCode NOT IN
										(SELECT productCode
										FROM tblProducts
										WHERE productCode LIKE 'EV%'
										AND (SUBSTRING(productCode, 5, 2) = '10'))
								  AND deleteX <> 'yes'
								  AND orderID = @orderID)
		WHERE CACP = 1
		AND EV10 = 1
		AND orderID = @orderID

		--cnCACP_EV10_DK
		UPDATE tblA1_CC
		SET cnCACP_EV10_DK = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT LIKE 'CACP%'
									  AND productCode NOT LIKE 'DK%'
									  AND productCode NOT IN
											(SELECT productCode
											FROM tblProducts
											WHERE productCode LIKE 'EV%'
											AND (SUBSTRING(productCode, 5, 2) = '10'))
									  AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE CACP = 1
		AND DK = 1
		AND EV10 = 1
		AND orderID = @orderID

		--cnCACP_EV10_ES
		UPDATE tblA1_CC
		SET cnCACP_EV10_ES = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT LIKE 'CACP%'
									  AND productCode NOT IN
											(SELECT productCode
											FROM tblProducts
											WHERE (productCode LIKE 'EV%'
													AND (SUBSTRING(productCode, 5, 2) = '10'))
											OR		(productCode LIKE 'ES%'
													AND productID NOT IN ('8039', '8040', '8041')))
									  AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE CACP = 1
		AND ES = 1
		AND EV10 = 1
		AND orderID = @orderID

		--cnCACP_EV10_DK_ES
		UPDATE tblA1_CC
		SET cnCACP_EV10_DK_ES = (SELECT COUNT(DISTINCT(ID))
										  FROM tblOrders_Products
										  WHERE productCode NOT LIKE 'CACP%'
										  AND productCode NOT LIKE 'DK%'
										  AND productCode NOT IN
												(SELECT productCode
												FROM tblProducts
												WHERE (productCode LIKE 'EV%'
														AND (SUBSTRING(productCode, 5, 2) = '10'))
												OR		(productCode LIKE 'ES%'
														AND productID NOT IN ('8039', '8040', '8041')))
										  AND deleteX <> 'yes'
										  AND orderID = @orderID)
		WHERE CACP = 1
		AND DK = 1
		AND ES = 1
		AND EV10 = 1
		AND orderID = @orderID

		--cnQS
		UPDATE tblA1_CC
		SET cnQS = (SELECT COUNT(DISTINCT(ID))
						  FROM tblOrders_Products
						  WHERE productCode NOT IN
						  		(SELECT productCode
						  		 FROM tblProducts
						  		 WHERE SUBSTRING(productCode, 3, 2) = 'QS'
								 AND productType = 'Stock')
						  AND deleteX <> 'yes'
						  AND orderID = @orderID)
		WHERE QS = 1
		AND orderID = @orderID

		--cnQS_DK
		UPDATE tblA1_CC
		SET cnQS_DK = (SELECT COUNT(DISTINCT(ID))
							  FROM tblOrders_Products
						     WHERE productCode NOT IN
							  		(SELECT productCode
							  		 FROM tblProducts
							  		 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
											 AND productType = 'Stock')
									 OR productCode LIKE 'DK%')
							  AND deleteX <> 'yes'
							  AND orderID = @orderID)
		WHERE DK = 1
		AND QS = 1
		AND orderID = @orderID

		--cnQS_ES
		UPDATE tblA1_CC
		SET cnQS_ES = (SELECT COUNT(DISTINCT(ID))
							  FROM tblOrders_Products
							  WHERE productCode NOT IN
									(SELECT productCode
									FROM tblProducts
									WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
											AND productType = 'Stock')
									OR		(productCode LIKE 'ES%'
											AND productID NOT IN ('8039', '8040', '8041')))
							  AND deleteX <> 'yes'
							  AND orderID = @orderID)
		WHERE ES = 1
		AND QS = 1
		AND orderID = @orderID

		--cnQS_DK_ES
		UPDATE tblA1_CC
		SET cnQS_DK_ES = (SELECT COUNT(DISTINCT(ID))
								  FROM tblOrders_Products
								  WHERE productCode NOT IN
									(SELECT productCode
									FROM tblProducts
									WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
											AND productType = 'Stock')
									OR		(productCode LIKE 'ES%'
											AND productID NOT IN ('8039', '8040', '8041'))
									OR		productCode LIKE 'DK%')
								  AND deleteX <> 'yes'
								  AND orderID = @orderID)
		WHERE DK = 1
		AND ES = 1
		AND QS = 1
		AND orderID = @orderID

		--cnQS_EV07
		UPDATE tblA1_CC
		SET cnQS_EV07 = (SELECT COUNT(DISTINCT(ID))
								  FROM tblOrders_Products
								  WHERE productCode NOT IN
						  				(SELECT productCode
						  				 FROM tblProducts
						  				 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
												 AND productType = 'Stock')
										 OR	 (productCode LIKE 'EV%'
												 AND (SUBSTRING(productCode, 5, 2) = '07')))
								  AND deleteX <> 'yes'
								  AND orderID = @orderID)
		WHERE QS = 1
		AND EV07 = 1
		AND orderID = @orderID

		--cnQS_EV07_DK
		UPDATE tblA1_CC
		SET cnQS_EV07_DK = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT IN
						  					(SELECT productCode
						  					 FROM tblProducts
						  					 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
													 AND productType = 'Stock')
											 OR	 (productCode LIKE 'EV%'
													 AND (SUBSTRING(productCode, 5, 2) = '07'))
											 OR	 productCode LIKE 'DK%')
						           AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE DK = 1
		AND QS = 1
		AND EV07 = 1
		AND orderID = @orderID

		--cnQS_EV07_ES
		UPDATE tblA1_CC
		SET cnQS_EV07_ES = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT IN
						  					(SELECT productCode
						  					 FROM tblProducts
						  					 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
													 AND productType = 'Stock')
											 OR	 (productCode LIKE 'EV%'
													 AND (SUBSTRING(productCode, 5, 2) = '07'))
											 OR	 (productCode LIKE 'ES%'
													 AND productID NOT IN ('8039', '8040', '8041')))
									  AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE ES = 1
		AND QS = 1
		AND EV07 = 1
		AND orderID = @orderID

		--cnQS_EV07_DK_ES
		UPDATE tblA1_CC
		SET cnQS_EV07_DK_ES = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT IN
						  					(SELECT productCode
						  					 FROM tblProducts
						  					 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
													 AND productType = 'Stock')
											 OR	 (productCode LIKE 'EV%'
													 AND (SUBSTRING(productCode, 5, 2) = '07'))
											 OR	 (productCode LIKE 'ES%'
													 AND productID NOT IN ('8039', '8040', '8041'))
											 OR	 productCode LIKE 'DK%')
									  AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE DK = 1
		AND ES = 1
		AND QS = 1
		AND EV07 = 1
		AND orderID = @orderID

		--cnQS_EV10
		UPDATE tblA1_CC
		SET cnQS_EV10 = (SELECT COUNT(DISTINCT(ID))
								  FROM tblOrders_Products
								  WHERE productCode NOT IN
						  				(SELECT productCode
						  				 FROM tblProducts
						  				 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
												 AND productType = 'Stock')
										 OR	 (productCode LIKE 'EV%'
												 AND (SUBSTRING(productCode, 5, 2) = '10')))
								  AND deleteX <> 'yes'
								  AND orderID = @orderID)
		WHERE QS = 1
		AND EV10 = 1
		AND orderID = @orderID

		--cnQS_EV10_DK
		UPDATE tblA1_CC
		SET cnQS_EV10_DK = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT IN
						  					(SELECT productCode
						  					 FROM tblProducts
						  					 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
													 AND productType = 'Stock')
											 OR	 (productCode LIKE 'EV%'
													 AND (SUBSTRING(productCode, 5, 2) = '10'))
											 OR	 productCode LIKE 'DK%')
						           AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE DK = 1
		AND QS = 1
		AND EV10 = 1
		AND orderID = @orderID

		--cnQS_EV10_ES
		UPDATE tblA1_CC
		SET cnQS_EV10_ES = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT IN
						  					(SELECT productCode
						  					 FROM tblProducts
						  					 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
													 AND productType = 'Stock')
											 OR	 (productCode LIKE 'EV%'
													 AND (SUBSTRING(productCode, 5, 2) = '10'))
											 OR	 (productCode LIKE 'ES%'
													 AND productID NOT IN ('8039', '8040', '8041')))
									  AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE ES = 1
		AND QS = 1
		AND EV10 = 1
		AND orderID = @orderID

		--cnQS_EV10_DK_ES
		UPDATE tblA1_CC
		SET cnQS_EV10_DK_ES = (SELECT COUNT(DISTINCT(ID))
									  FROM tblOrders_Products
									  WHERE productCode NOT IN
						  					(SELECT productCode
						  					 FROM tblProducts
						  					 WHERE (SUBSTRING(productCode, 3, 2) = 'QS'
													 AND productType = 'Stock')
											 OR	 (productCode LIKE 'EV%'
													 AND (SUBSTRING(productCode, 5, 2) = '10'))
											 OR	 (productCode LIKE 'ES%'
													 AND productID NOT IN ('8039', '8040', '8041'))
											 OR	 productCode LIKE 'DK%')
									  AND deleteX <> 'yes'
									  AND orderID = @orderID)
		WHERE DK = 1
		AND ES = 1
		AND QS = 1
		AND EV10 = 1
		AND orderID = @orderID

		SET @RowCount = @RowCount + 1
	END
IF OBJECT_ID(N'tempPSU_A1CC', N'U') IS NOT NULL 
DROP TABLE tempPSU_A1CC

UPDATE tblA1_CC SET cnCACP = 0 WHERE cnCACP IS NULL
UPDATE tblA1_CC SET cnCACP_DK = 0 WHERE cnCACP_DK IS NULL
UPDATE tblA1_CC SET cnCACP_ES = 0 WHERE cnCACP_ES IS NULL
UPDATE tblA1_CC SET cnCACP_DK_ES = 0 WHERE cnCACP_DK_ES IS NULL
UPDATE tblA1_CC SET cnCACP_EV07 = 0 WHERE cnCACP_EV07 IS NULL
UPDATE tblA1_CC SET cnCACP_EV07_DK = 0 WHERE cnCACP_EV07_DK IS NULL
UPDATE tblA1_CC SET cnCACP_EV07_ES = 0 WHERE cnCACP_EV07_ES IS NULL
UPDATE tblA1_CC SET cnCACP_EV07_DK_ES = 0 WHERE cnCACP_EV07_DK_ES IS NULL
UPDATE tblA1_CC SET cnCACP_EV10 = 0 WHERE cnCACP_EV10 IS NULL
UPDATE tblA1_CC SET cnCACP_EV10_DK = 0 WHERE cnCACP_EV10_DK IS NULL
UPDATE tblA1_CC SET cnCACP_EV10_ES = 0 WHERE cnCACP_EV10_ES IS NULL
UPDATE tblA1_CC SET cnCACP_EV10_DK_ES = 0 WHERE cnCACP_EV10_DK_ES IS NULL
UPDATE tblA1_CC SET cnQS = 0 WHERE cnQS IS NULL
UPDATE tblA1_CC SET cnQS_DK = 0 WHERE cnQS_DK IS NULL
UPDATE tblA1_CC SET cnQS_ES = 0 WHERE cnQS_ES IS NULL
UPDATE tblA1_CC SET cnQS_DK_ES = 0 WHERE cnQS_DK_ES IS NULL
UPDATE tblA1_CC SET cnQS_EV07 = 0 WHERE cnQS_EV07 IS NULL
UPDATE tblA1_CC SET cnQS_EV07_DK = 0 WHERE cnQS_EV07_DK IS NULL
UPDATE tblA1_CC SET cnQS_EV07_ES = 0 WHERE cnQS_EV07_ES IS NULL
UPDATE tblA1_CC SET cnQS_EV07_DK_ES = 0 WHERE cnQS_EV07_DK_ES IS NULL
UPDATE tblA1_CC SET cnQS_EV10 = 0 WHERE cnQS_EV10 IS NULL
UPDATE tblA1_CC SET cnQS_EV10_DK = 0 WHERE cnQS_EV10_DK IS NULL
UPDATE tblA1_CC SET cnQS_EV10_ES = 0 WHERE cnQS_EV10_ES IS NULL
UPDATE tblA1_CC SET cnQS_EV10_DK_ES = 0 WHERE cnQS_EV10_DK_ES IS NULL

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

--select * from tblA1_CC WHERE orderID IN  = 444692774
--Begin conditionIDs, now that all variables have been set above
-- conditionID = 12 / gbsShipClass = 2 --------------------------------------------------1CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 12, 
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND cnCACP = 0
	AND RDI = 'R')
	
-- conditionID = 13 / gbsShipClass = 2 --------------------------------------------------1CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 13, 
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND cnCACP_DK = 0	
	AND RDI = 'R')

-- conditionID = 14 / gbsShipClass = 2 --------------------------------------------------1CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 14, 
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0	
	AND RDI = 'R')

-- conditionID = 15 / gbsShipClass = 2 --------------------------------------------------1CP+ES+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 15,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0	
	AND RDI = 'R')

-- conditionID = 16 / gbsShipClass = 2 --------------------------------------------------1CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 16,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND cnCACP = 0
	AND RDI = 'B'
	AND UPSRural = 1)
	
-- conditionID = 17 / gbsShipClass = 2 --------------------------------------------------1CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 17,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND cnCACP_DK = 0	
	AND RDI = 'B'
	AND UPSRural = 1)

-- conditionID = 18 / gbsShipClass = 2 --------------------------------------------------1CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 18,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0	
	AND RDI = 'B'
	AND UPSRural = 1)

-- conditionID = 19 / gbsShipClass = 2 --------------------------------------------------1CP+ES+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 19,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0	
	AND RDI = 'B'
	AND UPSRural = 1)

-- conditionID = 20 / gbsShipClass = 2 --------------------------------------------------1QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 20,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND cnQS = 0
	AND RDI = 'R')

-- conditionID = 21 / gbsShipClass = 2 --------------------------------------------------1QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 21,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND cnQS_DK = 0	
	AND RDI = 'R')

-- conditionID = 22 / gbsShipClass = 2 --------------------------------------------------1QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 22,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0	
	AND RDI = 'R')

-- conditionID = 23 / gbsShipClass = 2 --------------------------------------------------1QS+ES+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 23,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0	
	AND RDI = 'R')

-- conditionID = 24 / gbsShipClass = 2 --------------------------------------------------1QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 24,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND cnQS = 0
	AND RDI = 'B'
	AND UPSRural = 1)
	
-- conditionID = 25 / gbsShipClass = 2 --------------------------------------------------1QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 25,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND cnQS_DK = 0	
	AND RDI = 'B'
	AND UPSRural = 1)

-- conditionID = 26 / gbsShipClass = 2 --------------------------------------------------1QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 26,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0	
	AND RDI = 'B'
	AND UPSRural = 1)

-- conditionID = 27 / gbsShipClass = 2 --------------------------------------------------1QS+ES+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 27,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0	
	AND RDI = 'B'
	AND UPSRural = 1)

-- conditionID = 28 / gbsShipClass = 3 --------------------------------------------------1CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 28,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10 = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 29 / gbsShipClass = 3 --------------------------------------------------1CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 29,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_DK = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 30 / gbsShipClass = 3 --------------------------------------------------1CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 30,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_ES = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 31 / gbsShipClass = 3 --------------------------------------------------1CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 31,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_DK_ES = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 32 / gbsShipClass = 3 --------------------------------------------------1CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 32,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10 = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 33 / gbsShipClass = 3 --------------------------------------------------1CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 33,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_DK = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 34 / gbsShipClass = 3 --------------------------------------------------1CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 34,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_ES = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 35 / gbsShipClass = 3 --------------------------------------------------1CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 35,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_DK_ES = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 36 / gbsShipClass = 8 --------------------------------------------------1CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 36,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10 = 0))
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 37 / gbsShipClass = 8 --------------------------------------------------1CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 37,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_DK = 0))
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 38 / gbsShipClass = 8 --------------------------------------------------1CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 38,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_ES = 0))
	AND RDI = 'R'	
	AND GBSZone = 8)

-- conditionID = 39 / gbsShipClass = 8 --------------------------------------------------1CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 39,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnCACP_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnCACP_EV10_DK_ES = 0))
	AND RDI = 'R'	
	AND GBSZone = 8)

-- conditionID = 40 / gbsShipClass = 3 --------------------------------------------------1QS+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 40,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10 = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 41 / gbsShipClass = 3 --------------------------------------------------1QS+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 41,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 42 / gbsShipClass = 3 --------------------------------------------------1QS+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 42,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_ES = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 43 / gbsShipClass = 3 --------------------------------------------------1QS+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 43,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK_ES = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 44 / gbsShipClass = 3 --------------------------------------------------1QS+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 44,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10 = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 45 / gbsShipClass = 3 --------------------------------------------------1QS+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 45,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 46 / gbsShipClass = 3 --------------------------------------------------1QS+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 46,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_ES = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 47 / gbsShipClass = 3 --------------------------------------------------1QS+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 47,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK_ES = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 48 / gbsShipClass = 8 --------------------------------------------------1QS+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 48,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10 = 0))
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 49 / gbsShipClass = 8 --------------------------------------------------1QS+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 49,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK = 0))
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 50 / gbsShipClass = 8 --------------------------------------------------1QS+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 50,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_ES = 0))
	AND RDI = 'R'	
	AND GBSZone = 8)

-- conditionID = 51 / gbsShipClass = 8 --------------------------------------------------1QS+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 51,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 1
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK_ES = 0))
	AND RDI = 'R'	
	AND GBSZone = 8)

-- conditionID = 52 / gbsShipClass = 3 --------------------------------------------------2QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 52,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND cnQS = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 53 / gbsShipClass = 3 --------------------------------------------------2QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 53,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 54 / gbsShipClass = 3 --------------------------------------------------2QS+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 54,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10 = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 55 / gbsShipClass = 3 --------------------------------------------------2QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 55,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnQS_DK = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 56 / gbsShipClass = 3 --------------------------------------------------2QS+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 56,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10_ES = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 57 / gbsShipClass = 3 --------------------------------------------------2QS+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 57,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 58 / gbsShipClass = 3 --------------------------------------------------2QS+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 58,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 59 / gbsShipClass = 3 --------------------------------------------------2QS+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 59,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK_ES = 0))
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 60 / gbsShipClass = 3 --------------------------------------------------2QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 60,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND cnQS = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 61 / gbsShipClass = 3 --------------------------------------------------2QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 61,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 62 / gbsShipClass = 3 --------------------------------------------------2QS+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 62,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10 = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 63 / gbsShipClass = 3 --------------------------------------------------2QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 63,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnQS_DK = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 64 / gbsShipClass = 3 --------------------------------------------------2QS+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 64,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10_ES = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 65 / gbsShipClass = 3 --------------------------------------------------2QS+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 65,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 66 / gbsShipClass = 3 --------------------------------------------------2QS+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 66,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 67 / gbsShipClass = 3 --------------------------------------------------2QS+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 67,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK_ES = 0))
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 2 AND 3)

-- conditionID = 68 / gbsShipClass = 8 --------------------------------------------------2QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 68,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND cnQS = 0
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 69 / gbsShipClass = 8 --------------------------------------------------2QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 69,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 70 / gbsShipClass = 8 --------------------------------------------------2QS+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 70,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10 = 0))
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 71 / gbsShipClass = 8 --------------------------------------------------2QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 71,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnQS_DK = 0
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 72 / gbsShipClass = 8 --------------------------------------------------2QS+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 72,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10_ES = 0))
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 73 / gbsShipClass = 8 --------------------------------------------------2QS+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 73,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 74 / gbsShipClass = 8 --------------------------------------------------2QS+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 74,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK = 0))
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 75 / gbsShipClass = 8 --------------------------------------------------2QS+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 75,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 1
		  AND cnQS_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 1
		  AND cnQS_EV10_DK_ES = 0))
	AND RDI = 'R'
	AND GBSZone = 8)

-- conditionID = 76 / gbsShipClass = 3 --------------------------------------------------2CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 76,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND cnCACP = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 77 / gbsShipClass = 3 --------------------------------------------------2CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 77,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 78 / gbsShipClass = 3 --------------------------------------------------2CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 78,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07 = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 79 / gbsShipClass = 3 --------------------------------------------------2CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 79,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnCACP_DK = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 80 / gbsShipClass = 3 --------------------------------------------------2CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 80,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07_ES = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 81 / gbsShipClass = 3 --------------------------------------------------2CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 81,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 82 / gbsShipClass = 3 --------------------------------------------------2CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 82,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 83 / gbsShipClass = 3 --------------------------------------------------2CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 83,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK_ES = 0
	AND RDI = 'R'
	AND GBSZone BETWEEN 1 AND 4)

-- conditionID = 84 / gbsShipClass = 8 --------------------------------------------------2CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 84,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND cnCACP = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 6 AND 8)

-- conditionID = 85 / gbsShipClass = 8 --------------------------------------------------2CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 85,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 6 AND 8)


-- conditionID = 86 / gbsShipClass = 8 --------------------------------------------------2CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 86,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07 = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 6 AND 8)

-- conditionID = 87 / gbsShipClass = 8 --------------------------------------------------2CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 87,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnCACP_DK = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 6 AND 8)

-- conditionID = 88 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 88,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 6 AND 8)

-- conditionID = 89 / gbsShipClass = 8 --------------------------------------------------2CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 89,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 6 AND 8)

-- conditionID = 90 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 90,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 6 AND 8)

-- conditionID = 91 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 91,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 6 AND 8)

-- conditionID = 92 / gbsShipClass = 8 --------------------------------------------------2CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 92,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND cnCACP = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 5)

-- conditionID = 93 / gbsShipClass = 8 --------------------------------------------------2CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 93,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 5)

-- conditionID = 94 / gbsShipClass = 8 --------------------------------------------------2CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 94,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07 = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 5)

-- conditionID = 95 / gbsShipClass = 8 --------------------------------------------------2CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 95,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnCACP_DK = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 5)

-- conditionID = 96 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 96,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 5)

-- conditionID = 97 / gbsShipClass = 8 --------------------------------------------------2CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 97,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 5)

-- conditionID = 98 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 98,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 5)

-- conditionID = 99 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 99,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 5)


-- conditionID = 100 / gbsShipClass = 3 --------------------------------------------------2CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 100,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND cnCACP = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 3)

-- conditionID = 101 / gbsShipClass = 3 --------------------------------------------------2CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 101,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 3)

-- conditionID = 102 / gbsShipClass = 3 --------------------------------------------------2CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 102,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07 = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 3)

-- conditionID = 103 / gbsShipClass = 3 --------------------------------------------------2CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 103,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnCACP_DK = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 3)

-- conditionID = 104 / gbsShipClass = 3 --------------------------------------------------2CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 104,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 3)

-- conditionID = 105 / gbsShipClass = 3 --------------------------------------------------2CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 105,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 3)

-- conditionID = 106 / gbsShipClass = 3 --------------------------------------------------2CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 106,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 3)

-- conditionID = 107 / gbsShipClass = 3 --------------------------------------------------2CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 107,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 3)

-- conditionID = 108 / gbsShipClass = 8 --------------------------------------------------2CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 108, 
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND cnCACP = 0
	AND RDI = 'B'
	AND GBSZone = 8)

-- conditionID = 109 / gbsShipClass = 8 --------------------------------------------------2CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 109,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND RDI = 'B'
	AND GBSZone = 8)


-- conditionID = 110 / gbsShipClass = 8 --------------------------------------------------2CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 110,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07 = 0
	AND RDI = 'B'
	AND GBSZone = 8)

-- conditionID = 111 / gbsShipClass = 8 --------------------------------------------------2CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 111,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnCACP_DK = 0
	AND RDI = 'B'
	AND GBSZone = 8)

-- conditionID = 112 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 112,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07_ES = 0
	AND RDI = 'B'
	AND GBSZone = 8)

-- conditionID = 113 / gbsShipClass = 8 --------------------------------------------------2CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 113,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND RDI = 'B'
	AND GBSZone = 8)

-- conditionID = 114 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 114,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK = 0
	AND RDI = 'B'
	AND GBSZone = 8)

-- conditionID = 115 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 115,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK_ES = 0
	AND RDI = 'B'
	AND GBSZone = 8)

-- conditionID = 116 / gbsShipClass = 8 --------------------------------------------------2CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 116,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND cnCACP = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 117 / gbsShipClass = 8 --------------------------------------------------2CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 117,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 118 / gbsShipClass = 8 --------------------------------------------------2CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 118,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07 = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 119 / gbsShipClass = 8 --------------------------------------------------2CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 119,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND cnCACP_DK = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 120 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 120,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 2
	AND cnCACP_EV07_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 121 / gbsShipClass = 8 --------------------------------------------------2CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 121,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 122 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 122,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 123 / gbsShipClass = 8 --------------------------------------------------2CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 123,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY = 1
	AND cnCACP_EV07_DK_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 124 / gbsShipClass = 5 --------------------------------------------------2CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 124,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND EV10 = 1
	AND EV10_QTY BETWEEN 1 AND 2
	AND cnCACP_EV10 = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 125 / gbsShipClass = 5 --------------------------------------------------2CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 125,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV10 = 1
	AND EV10_QTY BETWEEN 1 AND 2
	AND cnCACP_EV10_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 126 / gbsShipClass = 5 --------------------------------------------------2CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 126,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND EV10 = 1
	AND EV10_QTY BETWEEN 1 AND 2
	AND cnCACP_EV10_DK = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 127 / gbsShipClass = 5 --------------------------------------------------2CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 127,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 2
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV10 = 1
	AND EV10_QTY BETWEEN 1 AND 2
	AND cnCACP_EV10_DK_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 7)

-- conditionID = 128 / gbsShipClass = 5 --------------------------------------------------3CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 128,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND cnCACP = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 129 / gbsShipClass = 5 --------------------------------------------------3CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 129,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 130 / gbsShipClass = 5 --------------------------------------------------3CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 130,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 3
	AND cnCACP_EV07 = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 131 / gbsShipClass = 5 --------------------------------------------------3CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 131,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND EV10 = 1
	AND EV10_QTY BETWEEN 1 AND 2
	AND cnCACP_EV10 = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 132 / gbsShipClass = 5 --------------------------------------------------3CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 132,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 3
	AND cnCACP_DK = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 133 / gbsShipClass = 5 --------------------------------------------------3CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 133,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 3
	AND cnCACP_EV07_ES = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 134 / gbsShipClass = 5 --------------------------------------------------3CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 134,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV10 = 1
	AND EV10_QTY BETWEEN 1 AND 2
	AND cnCACP_EV10_ES = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 135 / gbsShipClass = 5 --------------------------------------------------3CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 135,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 136 / gbsShipClass = 5 --------------------------------------------------3CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 136,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 3
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 3
	AND cnCACP_EV07_DK = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 137 / gbsShipClass = 5 --------------------------------------------------3CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 137,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV10 = 1
	AND EV10_QTY BETWEEN 1 AND 2
	AND cnCACP_EV10_DK = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 138 / gbsShipClass = 5 --------------------------------------------------3CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 138,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV07 = 1
	AND EV07_QTY BETWEEN 1 AND 3
	AND cnCACP_EV07_DK_ES = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 139 / gbsShipClass = 5 --------------------------------------------------3CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 139,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND EV10 = 1
	AND EV10_QTY BETWEEN 1 AND 2
	AND cnCACP_EV10_DK_ES = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 140 / gbsShipClass = 4 --------------------------------------------------3CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 140,
	 a1_mailPieceShape = @GSC4_mailPieceShape,
	 a1_mailClass = @GSC4_mailClass,
	 a1_carrier = @GSC4_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND cnCACP = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 8)

-- conditionID = 141 / gbsShipClass = 4 --------------------------------------------------3CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 141,
	 a1_mailPieceShape = @GSC4_mailPieceShape,
	 a1_mailClass = @GSC4_mailClass,
	 a1_carrier = @GSC4_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 8)

-- conditionID = 142 / gbsShipClass = 4 --------------------------------------------------3CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 142,
	 a1_mailPieceShape = @GSC4_mailPieceShape,
	 a1_mailClass = @GSC4_mailClass,
	 a1_carrier = @GSC4_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND DK = 1
	AND DK_QTY = 1
	AND cnCACP_DK = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 8)

-- conditionID = 143 / gbsShipClass = 4 --------------------------------------------------3CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 143,
	 a1_mailPieceShape = @GSC4_mailPieceShape,
	 a1_mailClass = @GSC4_mailClass,
	 a1_carrier = @GSC4_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 3
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone = 8)

-- conditionID = 144 / gbsShipClass = 6 --------------------------------------------------4CP
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 144,
	 a1_mailPieceShape = @GSC6_mailPieceShape,
	 a1_mailClass = @GSC6_mailClass,
	 a1_carrier = @GSC6_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 4
	AND cnCACP = 0
	AND shipState IN ('HI', 'AK'))

-- conditionID = 145 / gbsShipClass = 6 --------------------------------------------------4CP+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 145,
	 a1_mailPieceShape = @GSC6_mailPieceShape,
	 a1_mailClass = @GSC6_mailClass,
	 a1_carrier = @GSC6_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 4
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_ES = 0
	AND shipState IN ('HI', 'AK'))

-- conditionID = 146 / gbsShipClass = 6 --------------------------------------------------4CP+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 146,
	 a1_mailPieceShape = @GSC6_mailPieceShape,
	 a1_mailClass = @GSC6_mailClass,
	 a1_carrier = @GSC6_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 4
	AND DK = 1
	AND DK_QTY = 4
	AND cnCACP_DK = 0
	AND shipState IN ('HI', 'AK'))

-- conditionID = 147 / gbsShipClass = 6 --------------------------------------------------4CP+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 147,
	 a1_mailPieceShape = @GSC6_mailPieceShape,
	 a1_mailClass = @GSC6_mailClass,
	 a1_carrier = @GSC6_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 4
	AND DK = 1
	AND DK_QTY = 4
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnCACP_DK_ES = 0
	AND shipState IN ('HI', 'AK'))

-- conditionID = 148 / gbsShipClass = 6 --------------------------------------------------4CP+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 148,
	 a1_mailPieceShape = @GSC6_mailPieceShape,
	 a1_mailClass = @GSC6_mailClass,
	 a1_carrier = @GSC6_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 4
	AND ((EV07 = 1
		  AND EV07_QTY = 2
		  AND cnCACP_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 2
		  AND cnCACP_EV10 = 0))
	AND shipState IN ('HI', 'AK'))

-- conditionID = 149 / gbsShipClass = 6 --------------------------------------------------4CP+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 149,
	 a1_mailPieceShape = @GSC6_mailPieceShape,
	 a1_mailClass = @GSC6_mailClass,
	 a1_carrier = @GSC6_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 4
	AND DK = 1
	AND DK_QTY = 2
	AND ((EV07 = 1
		  AND EV07_QTY = 2
		  AND cnCACP_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 2
		  AND cnCACP_EV10_DK = 0))
	AND shipState IN ('HI', 'AK'))

-- conditionID = 150 / gbsShipClass = 6 --------------------------------------------------4CP+ENV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 150,
	 a1_mailPieceShape = @GSC6_mailPieceShape,
	 a1_mailClass = @GSC6_mailClass,
	 a1_carrier = @GSC6_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 4
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 2
		  AND cnCACP_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 2
		  AND cnCACP_EV10_ES = 0))
	AND shipState IN ('HI', 'AK'))

-- conditionID = 151 / gbsShipClass = 6 --------------------------------------------------4CP+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 151,
	 a1_mailPieceShape = @GSC6_mailPieceShape,
	 a1_mailClass = @GSC6_mailClass,
	 a1_carrier = @GSC6_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE CACP = 1
	AND CACP_QTY = 4
	AND DK = 1
	AND DK_QTY = 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY = 2
		  AND cnCACP_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY = 2
		  AND cnCACP_EV10_DK_ES = 0))
	AND shipState IN ('HI', 'AK'))


-- conditionID = 152 / gbsShipClass = 8 --------------------------------------------------3QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 152,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND cnQS = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 8)

-- conditionID = 153 / gbsShipClass = 8 --------------------------------------------------3QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 153,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 8)

-- conditionID = 154 / gbsShipClass = 8 --------------------------------------------------3QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 154,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND DK = 1
	AND DK_QTY = 1
	AND cnQS_DK = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 8)

-- conditionID = 155 / gbsShipClass = 8 --------------------------------------------------3QS+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 155,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0
	AND RDI = 'R'
	AND UPSRural = 1
	AND GBSZone BETWEEN 1 AND 8)

-- conditionID = 156 / gbsShipClass = 8 --------------------------------------------------3QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 156,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND cnQS = 0
	AND RDI = 'R'
	AND UPSRural = 0
	AND (GBSZone BETWEEN 2 AND 4
		 OR GBSZone BETWEEN 7 AND 8))

-- conditionID = 157 / gbsShipClass = 8 --------------------------------------------------3QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 157,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0
	AND RDI = 'R'
	AND UPSRural = 0
	AND (GBSZone BETWEEN 2 AND 4
		 OR GBSZone BETWEEN 7 AND 8))

-- conditionID = 158 / gbsShipClass = 8 --------------------------------------------------3QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 158,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND DK = 1
	AND DK_QTY = 1
	AND cnQS_DK = 0
	AND RDI = 'R'
	AND UPSRural = 0
	AND (GBSZone BETWEEN 2 AND 4
		 OR GBSZone BETWEEN 7 AND 8))

-- conditionID = 159 / gbsShipClass = 8 --------------------------------------------------3QS+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 159,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0
	AND RDI = 'R'
	AND UPSRural = 0
	AND (GBSZone BETWEEN 2 AND 4
		 OR GBSZone BETWEEN 7 AND 8))

-- conditionID = 160 / gbsShipClass = 8 --------------------------------------------------3QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 160,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND cnQS = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 8)

-- conditionID = 161 / gbsShipClass = 8 --------------------------------------------------3QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 161,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 8)

-- conditionID = 162 / gbsShipClass = 8 --------------------------------------------------3QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 162,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND DK = 1
	AND DK_QTY = 1
	AND cnQS_DK = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 8)

-- conditionID = 163 / gbsShipClass = 8 --------------------------------------------------3QS+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 163,
	 a1_mailPieceShape = @GSC8_mailPieceShape,
	 a1_mailClass = @GSC8_mailClass,
	 a1_carrier = @GSC8_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 3
	AND DK = 1
	AND DK_QTY = 1
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0
	AND RDI = 'B'
	AND UPSRural = 1
	AND GBSZone = 8)

-- conditionID = 164 / gbsShipClass = 5 --------------------------------------------------4QS
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 164,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 4
	AND cnQS = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 165 / gbsShipClass = 5 --------------------------------------------------4QS+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 165,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 4
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_ES = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 166 / gbsShipClass = 5 --------------------------------------------------4QS+ENV
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 166,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 4
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07 = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10 = 0))
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 167 / gbsShipClass = 5 --------------------------------------------------4QS+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 167,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 4
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 4
	AND cnQS_DK = 0
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 168 / gbsShipClass = 5 --------------------------------------------------4QS+EV+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 168,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 4
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10_ES = 0))
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 169 / gbsShipClass = 5 --------------------------------------------------4QS+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 169,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 4
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 4
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND cnQS_DK_ES = 0	
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 170 / gbsShipClass = 5 --------------------------------------------------4QS+ENV+DK
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 170,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 4
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07_DK = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10_DK = 0))
	AND RDI = 'R'
	AND GBSZone = 2)

-- conditionID = 171 / gbsShipClass = 5 --------------------------------------------------4QS+ENV+DK+ES
UPDATE tblOrders
SET a1 = 1, a1_conditionID = 171,
	 a1_mailPieceShape = @GSC5_mailPieceShape,
	 a1_mailClass = @GSC5_mailClass,
	 a1_carrier = @GSC5_carrier
WHERE orderID IN
	(SELECT orderID
	FROM tblA1_CC
	WHERE QS = 1
	AND QS_QTY = 4
	AND DK = 1
	AND DK_QTY BETWEEN 1 AND 2
	AND ES = 1
	AND ES_QTY BETWEEN 1 AND 10
	AND ((EV07 = 1
		  AND EV07_QTY BETWEEN 1 AND 2
		  AND cnQS_EV07_DK_ES = 0)
		 OR
		  (EV10 = 1
		  AND EV10_QTY BETWEEN 1 AND 2
		  AND cnQS_EV10_DK_ES = 0))
	AND RDI = 'R'
	AND GBSZone = 2)

--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--// 2. WEB (Marketplace)
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////

-- conditionID = 1 / gbsShipClass = 1 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 1,
	 a1_mailPieceShape = @GSC1_mailPieceShape,
	 a1_mailClass = @GSC1_mailClass,
	 a1_carrier = @GSC1_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 1)
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)

-- conditionID = 2 / gbsShipClass = 2 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 2,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
	AND [quantity-purchased] >= 2
	AND [quantity-purchased] <= 4
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 1)
AND rdi = 'R'
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)


-- conditionID = 3 / gbsShipClass = 2 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 3,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
	AND [quantity-purchased] IN (2, 3, 4)
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 1)
AND rdi = 'B'
AND UPSRural = 1
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)


-- conditionID = 4 / gbsShipClass = 2 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 4,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 1)
AND rdi = 'R'
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)

-- conditionID = 5 / gbsShipClass = 2 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 5,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 1)
AND rdi = 'B'
AND UPSRural = 1
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)

-- conditionID = 6 / gbsShipClass = 2 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 6,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 2)
AND rdi = 'R'
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)


-- conditionID = 7 / gbsShipClass = 2 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 7,
	 a1_mailPieceShape = @GSC2_mailPieceShape,
	 a1_mailClass = @GSC2_mailClass,
	 a1_carrier = @GSC2_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 2)
AND rdi = 'B'
AND UPSRural = 1
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)

-- conditionID = 8 / gbsShipClass = 3 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 8,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 2
	AND [ship-service-level] = 'Standard')
AND SUBSTRING([ship-postal-code], 1, 3) IN
	(SELECT zip
	FROM tblZone
	WHERE GBSZone IN (2, 3, 4))
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 1)
AND rdi = 'R'
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)

-- conditionID = 9 / gbsShipClass = 3 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 9,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 2
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND SUBSTRING([ship-postal-code], 1, 3) IN
	(SELECT zip
	FROM tblZone
	WHERE GBSZone IN (2, 3, 4))
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 2)
AND rdi = 'R'
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)

-- conditionID = 10 / gbsShipClass = 3 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 10,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
	AND [quantity-purchased] IN (2, 3, 4)
	AND [ship-service-level] = 'Standard')
AND SUBSTRING([ship-postal-code], 1, 3) IN
	(SELECT zip
	FROM tblZone
	WHERE GBSZone IN (2, 3, 4))
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 2)
AND rdi = 'R'
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)

-- conditionID = 11 / gbsShipClass = 3 --------------------------------------------------
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 11,
	 a1_mailPieceShape = @GSC3_mailPieceShape,
	 a1_mailClass = @GSC3_mailClass,
	 a1_carrier = @GSC3_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
	AND [quantity-purchased] IN (5, 6, 7)
	AND [ship-service-level] = 'Standard')
AND SUBSTRING([ship-postal-code], 1, 3) IN
	(SELECT zip
	FROM tblZone
	WHERE GBSZone IN (2, 3, 4))
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	GROUP BY orderNo
	HAVING COUNT(orderNo) = 1)
AND rdi = 'R'
AND isValidated = 1
AND a1 = 0
AND a1_processed = 0
AND a1_printed = 0
AND (returnCode = 31 OR returnCode = 32)

-- conditionID = 172 / gbsShipClass = 7 -------------------------------------------------- UPS
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 172,
	 a1_mailPieceShape = @GSC7_mailPieceShape,
	 a1_mailClass = @GSC7_mailClass,
	 a1_carrier = @GSC7_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
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
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 173,
	 a1_mailPieceShape = @GSC7_mailPieceShape,
	 a1_mailClass = @GSC7_mailClass,
	 a1_carrier = @GSC7_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
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
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 174,
	 a1_mailPieceShape = @GSC7_mailPieceShape,
	 a1_mailClass = @GSC7_mailClass,
	 a1_carrier = @GSC7_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
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
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 175,
	 a1_mailPieceShape = @GSC7_mailPieceShape,
	 a1_mailClass = @GSC7_mailClass,
	 a1_carrier = @GSC7_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
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
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 176,
	 a1_mailPieceShape = @GSC7_mailPieceShape,
	 a1_mailClass = @GSC7_mailClass,
	 a1_carrier = @GSC7_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
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
UPDATE tblAMZ_orderShip
SET a1 = 1, a1_conditionID = 177,
	 a1_mailPieceShape = @GSC7_mailPieceShape,
	 a1_mailClass = @GSC7_mailClass,
	 a1_carrier = @GSC7_carrier
WHERE orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE [product-name] LIKE '%72%'
	AND [quantity-purchased] = 1
	AND [ship-service-level] = 'Standard')
AND orderNo IN
	(SELECT orderNo
	FROM tblAMZ_orderValid
	WHERE ([product-name] LIKE '24%'
			OR [product-name] LIKE '%24 cards%')
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

--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////
/*--Save this old version of HOM/NCC A1 code; 11/28/16; jf.

UPDATE tblOrders
SET a1 = 1
WHERE 
a1 = 0
AND orderID IN 
		(SELECT a.orderID
		FROM tblOrders a
		JOIN tblCustomers c
			ON a.customerID = c.customerID
		JOIN tblCustomers_ShippingAddress s
			ON a.orderNo = s.orderNo
		WHERE
		--orders with valid orderStatus.
		a.orderStatus NOT IN ('failed', 'cancelled', 'delivered', 'On HOM Dock', 'In Transit', 'In Transit USPS', 'MIGZ')

		--orders which have not already had an A1 label generated. this field is updated by label creation.
		AND a.orderJustPrinted = 0

		--orders with valid payment.
		AND a.displayPaymentStatus = 'Good'

		--orders that are not custom (performance v. redundancy)
		AND a.orderType <> 'Custom'

		--and RDI is residential "R". Changed from tblOrders.rescom on 11/1/16; jf.
		AND s.rdi = 'R'

		--orders that have qualifying A1 products within, at a product quantity of "1" for numUnits * productQuantity; can only have a SUM of "1" per order in this criteria.
		AND a.orderID IN
			(SELECT orderID
			FROM tblOrders_Products op
			JOIN tblProducts pr
				ON op.productID = pr.productID
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
					--// Note Card Set (updated 2/17/16; jf; as per KH: "A1 tickets should include a single order of a 72 note card pak for the padded envelope rate")
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
*/