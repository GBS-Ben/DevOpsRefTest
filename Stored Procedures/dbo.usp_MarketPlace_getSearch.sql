CREATE PROCEDURE [dbo].[usp_MarketPlace_getSearch]
@search VARCHAR(100),
@searchType VARCHAR(100)
AS
-------------------------------------------------------------------------------
-- Author      JF
-- Created     10/16/16
-- Purpose     This sproc grabs the searched for orders for display on 
--					http://intranet/gbs/admin/orders_marketPlace.asp
-- Variables	This sproc accepts 1 value for @search. See below.
-- Example:		EXEC usp_MarketPlace_getSearch 'WEB123456'
-------------------------------------------------------------------------------
-- Modification History
--
-- 10/16/16		Created.
-- 01/31/17		Added A1, RP2, a1_processed columns
-- 09/29/20		JF, added [order-id] searchability.
-------------------------------------------------------------------------------

IF @search <> ''
BEGIN
	--// grab data
	IF @searchType = 'customer'
	BEGIN
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		CONVERT(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		a.orderBatchedDate,
		a.orderPrintedDate,
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
		a.a1_processed
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE a.[buyer-name] LIKE '%' + @search + '%'
		OR a.[recipient-name] LIKE '%' + @search + '%'
		OR b.[buyer-name] LIKE '%' + @search + '%'
		OR b.[recipient-name] LIKE '%' + @search + '%'
		ORDER BY CONVERT(DATETIME, a.orderDate) DESC, a.orderNo DESC
	END

	IF @searchType = 'order'
	BEGIN
		SELECT DISTINCT
		a.orderNo, 
		a.[buyer-name] AS 'customerName',
		CONVERT(DATETIME, a.orderDate) AS 'orderDate',
		a.orderStatus,
		a.modified_on AS 'statusUpdate',
		b.[ship-service-level] AS 'shipMethod',
		a.orderBatchedDate,
		a.orderPrintedDate,
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
		a.a1_processed
		FROM tblAMZ_orderShip a
		LEFT JOIN tblAMZ_orderValid b
			ON a.orderNo = b.orderNo
		WHERE a.orderNo LIKE '%' + @search + '%'
		OR a.[order-id] LIKE '%' + @search + '%'
		ORDER BY CONVERT(DATETIME, a.orderDate) DESC, a.orderNo DESC
	END
END