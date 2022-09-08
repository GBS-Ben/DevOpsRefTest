CREATE PROCEDURE [dbo].[usp_MarketPlace_getTab]
@tab VARCHAR(50)
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/12/16
-- Purpose     This sproc grabs all AMZ orders for display on 
--					http://intranet/gbs/admin/orders_marketPlace.asp
-- Variables	This sproc accepts 4 different values for @tab. See below.
-- Example:		EXEC usp_MarketPlace_getTab 'New'
-------------------------------------------------------------------------------
-- Modification History
--
-- 7/12/16		Created.
-- 8/11/16		updated "shipped" section to include "delivered" too. created "all" section.
-- 12/16/16		updated each query with:
								--a.isValidated,
								--a.A1,
								--a.R2P
-- 4/3/17		updated each query with:
								--a.A1_conditionID,
								--a.A1,
								--a.a1_mailClass,
								--a.a1_carrier
--04/27/21		CKB, Markful
-------------------------------------------------------------------------------
SET NOCOUNT ON;
BEGIN TRY
	--// set var
	DECLARE @orderStatus VARCHAR (50) = ''

	IF @tab = 'New'
		BEGIN
		SET @orderStatus = 'In House'
		END

	IF @tab = 'In House'
		BEGIN
		SET @orderStatus = 'In House'
		END

	IF @tab = 'On HOM Dock'
		BEGIN
		SET @orderStatus = 'On MRK Dock'
		END

	IF @tab = 'On MRK Dock'
		BEGIN
		SET @orderStatus = 'On MRK Dock'
		END

	IF @tab = 'In Transit'
		BEGIN
		SET @orderStatus = 'Shipped'
		END

	IF @tab = 'Delivered'
		BEGIN
		SET @orderStatus = 'Delivered'
		END

	IF @tab = 'Shipped'
		BEGIN
		SET @orderStatus = 'Shipped'
		END

	IF @tab = 'All'
		BEGIN
		SET @orderStatus = 'All'
		END

	IF @tab = 'In House'
	BEGIN
		--// grab data
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		try_convert(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		CASE
			WHEN a.isValidated IS NULL THEN 'Pending'
			WHEN a.isValidated = 1 THEN 'Yes'
			WHEN a.isValidated = 0 THEN 'No'
			ELSE CONVERT(VARCHAR(50), a.isValidated)
		END as 'isValidated',
		CASE
			WHEN a.A1 IS NULL THEN 'Pending'
			WHEN a.A1 = 1 THEN 'A1'
			WHEN a.A1 = 0 THEN 'X1'
		END as 'A1',
		CASE
			WHEN a.R2P = 1 THEN 'Yes'
			WHEN a.R2P = 0 THEN 'No'
		END as 'R2P',
		a.a1_processed,
		a.a1_conditionID,
		a.a1_mailClass,
		a.a1_carrier
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE a.orderStatus = @orderStatus
		ORDER BY try_convert(DATETIME, a.orderDate) DESC, a.orderNo DESC
	END

	IF @tab = 'New'
	BEGIN
		--// grab data
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		try_convert(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		CASE
			WHEN a.isValidated IS NULL THEN 'Pending'
			WHEN a.isValidated = 1 THEN 'Yes'
			WHEN a.isValidated = 0 THEN 'No'
			ELSE CONVERT(VARCHAR(50), a.isValidated)
		END as 'isValidated',
		CASE
			WHEN a.A1 IS NULL THEN 'Pending'
			WHEN a.A1 = 1 THEN 'A1'
			WHEN a.A1 = 0 THEN 'X1'
		END as 'A1',
		CASE
			WHEN a.R2P = 1 THEN 'Yes'
			WHEN a.R2P = 0 THEN 'No'
		END as 'R2P',
		a.a1_processed,
		a.A1_conditionID,
		a.a1_mailClass,
		a.a1_carrier
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE a.orderAck = 0
		AND a.orderStatus = 'In House'
		ORDER BY a.A1_conditionID DESC, try_convert(DATETIME, a.orderDate) DESC, a.orderNo DESC
	END

	IF @orderStatus IN ('On HOM Dock','On MRK Dock')
	BEGIN
		--// grab data
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		try_convert(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		CASE
			WHEN a.isValidated IS NULL THEN 'Pending'
			WHEN a.isValidated = 1 THEN 'Yes'
			WHEN a.isValidated = 0 THEN 'No'
			ELSE CONVERT(VARCHAR(50), a.isValidated)
		END as 'isValidated',
		CASE
			WHEN a.A1 IS NULL THEN 'Pending'
			WHEN a.A1 = 1 THEN 'A1'
			WHEN a.A1 = 0 THEN 'X1'
		END as 'A1',
		CASE
			WHEN a.R2P = 1 THEN 'Yes'
			WHEN a.R2P = 0 THEN 'No'
		END as 'R2P',
		a.a1_processed,
		a.A1_conditionID,
		a.a1_mailClass,
		a.a1_carrier
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE a.orderStatus = @orderStatus
		AND DATEDIFF(DD, a.orderDate, GETDATE()) <= 90
		ORDER BY try_convert(DATETIME, a.orderDate) DESC, a.orderNo DESC	
	END

	IF @orderStatus = 'Shipped'
	BEGIN
		--// grab data
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		try_convert(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		CASE
			WHEN a.isValidated IS NULL THEN 'Pending'
			WHEN a.isValidated = 1 THEN 'Yes'
			WHEN a.isValidated = 0 THEN 'No'
			ELSE CONVERT(VARCHAR(50), a.isValidated)
		END as 'isValidated',
		CASE
			WHEN a.A1 IS NULL THEN 'Pending'
			WHEN a.A1 = 1 THEN 'A1'
			WHEN a.A1 = 0 THEN 'X1'
		END as 'A1',
		CASE
			WHEN a.R2P = 1 THEN 'Yes'
			WHEN a.R2P = 0 THEN 'No'
		END as 'R2P',
		a.a1_processed,
		a.A1_conditionID,
		a.a1_mailClass,
		a.a1_carrier
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE (a.orderStatus = @orderStatus
				OR a.orderStatus = 'Delivered')
		AND DATEDIFF(DD, a.orderDate, GETDATE()) <= 90
		ORDER BY try_convert(DATETIME, a.orderDate) DESC, a.orderNo DESC	
	END

	IF @orderStatus = 'Delivered'
	BEGIN
		--// grab data
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		try_convert(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		CASE
			WHEN a.isValidated IS NULL THEN 'Pending'
			WHEN a.isValidated = 1 THEN 'Yes'
			WHEN a.isValidated = 0 THEN 'No'
			ELSE CONVERT(VARCHAR(50), a.isValidated)
		END as 'isValidated',
		CASE
			WHEN a.A1 IS NULL THEN 'Pending'
			WHEN a.A1 = 1 THEN 'A1'
			WHEN a.A1 = 0 THEN 'X1'
		END as 'A1',
		CASE
			WHEN a.R2P = 1 THEN 'Yes'
			WHEN a.R2P = 0 THEN 'No'
		END as 'R2P',
		a.a1_processed,
		a.A1_conditionID,
		a.a1_mailClass,
		a.a1_carrier
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE a.orderStatus = @orderStatus
		AND DATEDIFF(DD, a.orderDate, GETDATE()) <= 90
		ORDER BY try_convert(DATETIME, a.orderDate) DESC, a.orderNo DESC
	END

	IF @orderStatus = 'All'
	BEGIN
		--// grab data
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		try_convert(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		CASE
			WHEN a.isValidated IS NULL THEN 'Pending'
			WHEN a.isValidated = 1 THEN 'Yes'
			WHEN a.isValidated = 0 THEN 'No'
			ELSE CONVERT(VARCHAR(50), a.isValidated)
		END as 'isValidated',
		CASE
			WHEN a.A1 IS NULL THEN 'Pending'
			WHEN a.A1 = 1 THEN 'A1'
			WHEN a.A1 = 0 THEN 'X1'
		END as 'A1',
		CASE
			WHEN a.R2P = 1 THEN 'Yes'
			WHEN a.R2P = 0 THEN 'No'
		END as 'R2P',
		a.a1_processed,
		a.A1_conditionID,
		a.a1_mailClass,
		a.a1_carrier
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE DATEDIFF(DD, a.orderDate, GETDATE()) <= 90
		ORDER BY try_convert(DATETIME, a.orderDate) DESC, a.orderNo DESC	
	END

	IF @tab = 'RecPrint'
	BEGIN
		--// grab data
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		try_convert(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		CASE
			WHEN a.isValidated IS NULL THEN 'Pending'
			WHEN a.isValidated = 1 THEN 'Yes'
			WHEN a.isValidated = 0 THEN 'No'
			ELSE CONVERT(VARCHAR(50), a.isValidated)
		END as 'isValidated',
		CASE
			WHEN a.A1 IS NULL THEN 'Pending'
			WHEN a.A1 = 1 THEN 'A1'
			WHEN a.A1 = 0 THEN 'X1'
		END as 'A1',
		CASE
			WHEN a.R2P = 1 THEN 'Yes'
			WHEN a.R2P = 0 THEN 'No'
		END as 'R2P',
		a.a1_processed,
		a.A1_conditionID,
		a.a1_mailClass,
		a.a1_carrier
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE DATEDIFF(DD, a.orderBatchedDate, GETDATE()) <= 7
		ORDER BY try_convert(DATETIME, a.orderDate) DESC, a.orderNo DESC
	END

	
END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH