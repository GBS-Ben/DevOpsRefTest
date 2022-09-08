----****************************************************************************************************************************
----****************************************************************************************************************************
----****************************************************************************************************************************

CREATE PROC [dbo].[Report_Customer365]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     03/10/20
Purpose     Rolling 365 on customer data
------------------------------------------------------------------------------
Modification History

03/10/20	New

-------------------------------------------------------------------------------
*/
--create temp tables

IF OBJECT_ID('tempdb..#reportTopCustomers') IS NOT NULL
DROP TABLE tempdb..#reportTopCustomers

CREATE TABLE tempdb..#reportTopCustomers(
	customerID INT NOT NULL,
	parentID INT,
	MCID VARCHAR(MAX),
	email VARCHAR (255),
	numOrders_last365 INT,
	avgOrdersPerMonth INT,
	lastOrderDate DATETIME,
	codesUsed BIT NOT NULL DEFAULT 0,
	MonthlyBilling BIT NOT NULL DEFAULT 0,
	lessThan30 INT,
	between31and60 INT,
	between61and90 INT,
	between91and365 INT,
	revenue_last365 MONEY,
	revenue_YOY MONEY,
	BP_last365 BIT NOT NULL DEFAULT 0,
	NB_last365 BIT NOT NULL DEFAULT 0,
	CM_last365 BIT NOT NULL DEFAULT 0,
	SN_last365 BIT NOT NULL DEFAULT 0,
	AP_last365 BIT NOT NULL DEFAULT 0,
	NC_last365 BIT NOT NULL DEFAULT 0,
	FD_last365 BIT NOT NULL DEFAULT 0,
	Other_last365 BIT NOT NULL DEFAULT 0,
	BP_lastOrder DATETIME,
	NB_lastOrder DATETIME,
	CM_lastOrder DATETIME,
	SN_lastOrder DATETIME,
	AP_lastOrder DATETIME,
	NC_lastOrder DATETIME,
	FD_lastOrder DATETIME,
	Other_lastOrder DATETIME)

--tblOrders_Products
IF OBJECT_ID('tempdb..#tempJF_OP') IS NOT NULL
DROP TABLE #tempJF_OP

CREATE TABLE #tempJF_OP(
	PKID INT NOT NULL,
	OrderID INT NOT NULL,
	ProductCode VARCHAR (255) NOT NULL,
	ProductName VARCHAR (255) NOT NULL,
	ProductQuantity INT NOT NULL)

INSERT INTO #tempJF_OP (PKID, OrderID, ProductCode, ProductName, ProductQuantity)
SELECT ID, op.orderID, productCode, productName, productQuantity
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderDate > DATEADD(DD, -366, GETDATE())
AND op.DeleteX <> 'yes'

--tblOrders & tblCustomers
IF OBJECT_ID('tempdb..#tempJF_OC') IS NOT NULL
DROP TABLE #tempJF_OC

CREATE TABLE #tempJF_OC(
	orderID INT NOT NULL,
	orderDate DATETIME NOT NULL,
	orderStatus VARCHAR (255) NOT NULL,
	orderTotal MONEY,
	calcOrderTotal MONEY,
	paymentMethod VARCHAR (255),
	customerID INT NOT NULL,
	email VARCHAR (255))

INSERT INTO #tempJF_OC (orderID, orderDate, orderStatus, orderTotal, calcOrderTotal, paymentMethod, customerID, email)
SELECT orderID, orderDate, orderStatus, orderTotal, calcOrderTotal, paymentMethod, c.customerID, c.email
FROM tblOrders o
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderDate > DATEADD(DD, -366, GETDATE())

----**************************
--populate initial data
;WITH CTE
AS
(SELECT email, CONVERT(DECIMAL(10,2), SUM(ISNULL(calcOrderTotal, orderTotal))) AS 'totalRev'
FROM #tempJF_OC
WHERE orderStatus NOT IN ('cancelled', 'failed')
AND orderDate > DATEADD(DD, -366, GETDATE())
GROUP BY email
)

INSERT INTO tempdb..#reportTopCustomers (customerID, email, revenue_last365)
SELECT oc.customerID, oc.email, 
cte.totalRev
FROM #tempJF_OC oc
INNER JOIN cte ON oc.email = cte.email
WHERE oc.orderStatus NOT IN ('cancelled', 'failed')
AND oc.orderDate > DATEADD(DD, -366, GETDATE())
GROUP BY oc.email, oc.customerID, cte.totalRev
HAVING COUNT(oc.email) > 9
ORDER BY COUNT(oc.email) DESC

----**************************
--YOY Rev
;WITH CTE
AS
(SELECT c.email,
SUM(ISNULL(o.calcOrderTotal, o.orderTotal)) AS 'revenue_YOY'
FROM tblOrders o
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderDate BETWEEN DATEADD(DD, -731, GETDATE()) AND DATEADD(DD, -366, GETDATE())
AND EXISTS
	(SELECT TOP 1 1
	FROM #reportTopCustomers r
	WHERE c.email = r.email)
GROUP BY c.email)

UPDATE r
SET revenue_YOY = CTE.revenue_YOY
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

UPDATE r
SET revenue_YOY = 0
FROM #reportTopCustomers r 
WHERE revenue_YOY IS NULL

----**************************
--last orderDate per email
IF OBJECT_ID('tempdb..#tempLastOrder') IS NOT NULL
DROP TABLE #tempLastOrder
CREATE TABLE #tempLastOrder 
	(
	 rowID INT IDENTITY(1, 1), 
	 email VARCHAR(255)
	)
DECLARE @NumberRecords INT, 
		@RowCount INT,
		@email VARCHAR(255),
		@lastOrderDate DATETIME

INSERT INTO #tempLastOrder (email)
SELECT r.email
FROM #reportTopCustomers r

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
	SELECT @email = email
	FROM #tempLastOrder
	WHERE rowID = @RowCount

	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							WHERE @email = oc.email
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET lastOrderDate = @lastOrderDate
	WHERE email = @email

	SET @RowCount = @RowCount + 1
END

----**************************
--monthly billing
UPDATE r
SET MonthlyBilling = 1
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN tblOrders o ON oc.orderID = o.orderID
WHERE o.paymentMethod = 'Monthly Billing'

----**************************
--get date counts per email
DECLARE @DateCount_lessThan30 INT,
		@DateCount_between31and60 INT,
		@DateCount_between61and90 INT,
		@DateCount_between91and365 INT

SET @NumberRecords = 0
SET	@RowCount = 0
SET	@email = 0

TRUNCATE TABLE #tempLastOrder
INSERT INTO #tempLastOrder (email)
SELECT r.email
FROM #reportTopCustomers r

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
	SELECT @email = email
	FROM #tempLastOrder
	WHERE rowID = @RowCount

	SET @DateCount_lessThan30 = (SELECT COUNT(orderID)
								FROM #tempJF_OC oc
								WHERE @email = oc.email
								AND oc.orderDate BETWEEN DATEADD(DD, -30, GETDATE()) AND GETDATE())

	SET @DateCount_between31and60 = (SELECT COUNT(orderID)
									FROM #tempJF_OC oc
									WHERE @email = oc.email
									AND oc.orderDate BETWEEN DATEADD(DD, -60, GETDATE()) AND DATEADD(DD, -31, GETDATE()))

	SET @DateCount_between61and90 = (SELECT COUNT(orderID)
									FROM #tempJF_OC oc
									WHERE @email = oc.email
									AND oc.orderDate BETWEEN DATEADD(DD, -90, GETDATE()) AND DATEADD(DD, -61, GETDATE()))

	SET @DateCount_between91and365 = (SELECT COUNT(orderID)
									FROM #tempJF_OC oc
									WHERE @email = oc.email
									AND oc.orderDate BETWEEN DATEADD(DD, -365, GETDATE()) AND DATEADD(DD, -91, GETDATE()))

	UPDATE #reportTopCustomers
	SET lessThan30 = ISNULL(@DateCount_lessThan30, 0),
		between31and60 = ISNULL(@DateCount_between31and60, 0),
		between61and90 = ISNULL(@DateCount_between61and90, 0),
		between91and365 = ISNULL(@DateCount_between91and365, 0),
		numOrders_last365 = ISNULL(@DateCount_lessThan30, 0) + ISNULL(@DateCount_between31and60, 0) + ISNULL(@DateCount_between61and90, 0) + ISNULL(@DateCount_between91and365, 0),
		avgOrdersPerMonth = (ISNULL(@DateCount_lessThan30, 0) + ISNULL(@DateCount_between31and60, 0) + ISNULL(@DateCount_between61and90, 0) + ISNULL(@DateCount_between91and365, 0))/12
	WHERE email = @email	

	SET @RowCount = @RowCount + 1
END

----**************************
-- get MCIDs
IF OBJECT_ID('tempdb..#tempJF_MCID') IS NOT NULL
DROP TABLE #tempJF_MCID

CREATE TABLE #tempJF_MCID(
	email VARCHAR(255) NOT NULL,
	MCID VARCHAR (MAX))

INSERT INTO #tempJF_MCID (email, MCID)
SELECT DISTINCT r.email,
STUFF((SELECT DISTINCT ', ' + textValue
	   FROM tblOrdersProducts_productOptions oppz
	   INNER JOIN tblOrders_Products opp ON oppz.ordersProductsID = opp.ID
	   INNER JOIN tblOrders oo ON opp.orderID = oo.orderID
	   INNER JOIN tblCustomers cc ON oo.customerID = cc.customerID
	   WHERE r.email = cc.email
	   AND oppz.optionCaption = '10 Digit Company Code'
	   AND oo.orderStatus NOT IN ('failed', 'cancelled')
	   AND oppz.deleteX <> 'yes'
	   AND opp.deleteX <> 'yes'
	   FOR XML PATH('')), 1, 1, '') AS MCID
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
INNER JOIN tblCustomers c ON o.customerID = c.customerID
INNER JOIN #reportTopCustomers r ON c.email = r.email
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND op.deleteX <> 'yes'
AND oppx.optionCaption = '10 Digit Company Code'
AND oppx.deleteX <> 'yes'
GROUP BY r.email

UPDATE r
SET MCID = j.MCID
FROM #reportTopCustomers r
INNER JOIN #tempJF_MCID j ON r.email = j.email

----**************************
-- products purchased by customerID trailing 365

--Business Cards
;WITH CTE
AS
(SELECT DISTINCT r.email
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'BP')

UPDATE r
SET BP_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

--Name Badges
;WITH CTE
AS
(SELECT DISTINCT r.email
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'NB')

UPDATE r
SET NB_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

--Car Magnets
;WITH CTE
AS
(SELECT DISTINCT r.email
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'CM')

UPDATE r
SET CM_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

--Signs
;WITH CTE
AS
(SELECT DISTINCT r.email
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'SN')

UPDATE r
SET SN_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

--Apparel
;WITH CTE
AS
(SELECT DISTINCT r.email
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'AP')

UPDATE r
SET AP_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

--Notecards
;WITH CTE
AS
(SELECT DISTINCT r.email
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'NC')

UPDATE r
SET NC_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

--Folders
;WITH CTE
AS
(SELECT DISTINCT r.email
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'FD')

UPDATE r
SET FD_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

--Other Products
;WITH CTE
AS
(SELECT DISTINCT r.email
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.email = oc.email
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) NOT IN ('BP', 'NB', 'CM', 'SN', 'AP', 'NC', 'FD'))

UPDATE r
SET other_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.email = CTE.email

----**************************
-- get last ordered dates

IF OBJECT_ID('tempdb..#tempLastOrderDates') IS NOT NULL
DROP TABLE #tempLastOrderDates
CREATE TABLE #tempLastOrderDates 
	(
	 rowID INT IDENTITY(1, 1), 
	 email VARCHAR(255)
	)

SET @NumberRecords = 0
SET	@RowCount = 0
SET	@email = 0
SET @lastOrderDate = NULL

INSERT INTO #tempLastOrderDates (email)
SELECT r.email
FROM #reportTopCustomers r

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
	SELECT @email = email
	FROM #tempLastOrderDates
	WHERE rowID = @RowCount

	--BP
	SET @lastOrderDate = NULL
	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
							WHERE @email = oc.email
							AND LEFT(op.productCode, 2) = 'BP'
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET BP_lastOrder = @lastOrderDate
	WHERE email = @email

	--NB
	SET @lastOrderDate = NULL
	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
							WHERE @email = oc.email
							AND LEFT(op.productCode, 2) = 'NB'
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET NB_lastOrder = @lastOrderDate
	WHERE email = @email

	--CM
	SET @lastOrderDate = NULL
	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
							WHERE @email = oc.email
							AND LEFT(op.productCode, 2) = 'CM'
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET CM_lastOrder = @lastOrderDate
	WHERE email = @email

	--SN
	SET @lastOrderDate = NULL
	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
							WHERE @email = oc.email
							AND LEFT(op.productCode, 2) = 'SN'
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET SN_lastOrder = @lastOrderDate
	WHERE email = @email

	--AP
	SET @lastOrderDate = NULL
	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
							WHERE @email = oc.email
							AND LEFT(op.productCode, 2) = 'AP'
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET AP_lastOrder = @lastOrderDate
	WHERE email = @email

	--NC
	SET @lastOrderDate = NULL
	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
							WHERE @email = oc.email
							AND LEFT(op.productCode, 2) = 'NC'
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET NC_lastOrder = @lastOrderDate
	WHERE email = @email

	--FD
	SET @lastOrderDate = NULL
	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
							WHERE @email = oc.email
							AND LEFT(op.productCode, 2) = 'FD'
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET FD_lastOrder = @lastOrderDate
	WHERE email = @email

	--Other
	SET @lastOrderDate = NULL
	SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
							FROM #tempJF_OC oc
							INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
							WHERE @email = oc.email
							AND LEFT(op.productCode, 2) NOT IN ('BP', 'NB', 'CM', 'SN', 'AP', 'NC', 'FD')
							ORDER BY oc.orderDate DESC)

	UPDATE #reportTopCustomers
	SET Other_lastOrder = @lastOrderDate
	WHERE email = @email

	SET @RowCount = @RowCount + 1
END

----**************************
-- get data
SELECT * FROM #reportTopCustomers
ORDER BY numOrders_last365 DESC

----****************************************************************************************************************************
----****************************************************************************************************************************
----****************************************************************************************************************************
/*
SELECT * FROM tblcustomers where customerid = 444601495
SELECT * FROM tblOrders WHERE customerID  =559641686
SELECT * FROM #tempLastOrder
SELECT * FROM GBSWarehouse..Report_TopCustomers
SELECT * FROM #tempJF_OP
*/