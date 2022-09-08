CREATE proc [dbo].[GBSReports_TopCustomersTrailing365Days_REMAX] as

--1.	The first tab shows the “top customers” report for the trailing 365 days.

IF OBJECT_ID('tempdb..#reportTopCustomers') IS NOT NULL
DROP TABLE tempdb..#reportTopCustomers

CREATE TABLE tempdb..#reportTopCustomers(
       customerID INT NOT NULL,
       parentID INT,
       MCID VARCHAR(MAX),
	   MCName VARCHAR(MAX),
       
	   --new columns------------------
	   orderNo VARCHAR (255),
	   orderDate VARCHAR (255),
	   calcOrderTotal VARCHAR (255),
	   orderStatus VARCHAR (255),
	   firstName VARCHAR (255),
	   surname VARCHAR (255),
	   email VARCHAR (255),
	   phone VARCHAR (255),
	   shipping_company VARCHAR (255),
	   shipping_fullname VARCHAR (255),
	   shipping_street VARCHAR (255),
	   shipping_street2 VARCHAR (255),
	   shipping_suburb VARCHAR (255),
	   shipping_state VARCHAR (255),
	   shipping_postcode VARCHAR (255),
	   --------------------------------

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
       other BIT NOT NULL DEFAULT 0,
       BP_lastOrder DATETIME,
       NB_lastOrder DATETIME,
       CM_lastOrder DATETIME,
       SN_lastOrder DATETIME,
       AP_lastOrder DATETIME,
       NC_lastOrder DATETIME,
       FD_lastOrder DATETIME,
       other_lastOrder DATETIME)

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
AND op.GBSCOMPANYID LIKE 'RM%'

--tblOrders & tblCustomers
IF OBJECT_ID('tempdb..#tempJF_OC') IS NOT NULL
DROP TABLE #tempJF_OC

CREATE TABLE #tempJF_OC(
       orderID INT NOT NULL,
	   orderNo VARCHAR (255) NOT NULL,
       orderDate DATETIME NOT NULL,
       orderStatus VARCHAR (255) NOT NULL,
       orderTotal MONEY,
       calcOrderTotal MONEY,
       paymentMethod VARCHAR (255),
       customerID INT NOT NULL,
       email VARCHAR (255))

INSERT INTO #tempJF_OC (orderID, orderNo, orderDate, orderStatus, orderTotal, calcOrderTotal, paymentMethod, customerID, email)
SELECT orderID, orderNo, orderDate, orderStatus, orderTotal, calcOrderTotal, paymentMethod, c.customerID, c.email
FROM tblOrders o
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderDate > DATEADD(DD, -366, GETDATE())

----**************************
--populate initial data
;WITH CTE
AS
(SELECT customerID, CONVERT(DECIMAL(10,2), SUM(ISNULL(calcOrderTotal, orderTotal))) AS 'totalRev', orderNo
FROM #tempJF_OC
WHERE orderStatus NOT IN ('cancelled', 'failed')
AND orderDate > DATEADD(DD, -366, GETDATE())
GROUP BY customerID, orderNo
)

INSERT INTO tempdb..#reportTopCustomers (customerID, email, revenue_last365, orderNo)
SELECT oc.customerID, oc.email, 
cte.totalRev, cte.orderNo
FROM #tempJF_OC oc
INNER JOIN cte ON oc.customerID = cte.customerID
INNER JOIN tblOrders_Products op ON oc.orderID = op.orderID
WHERE oc.orderStatus NOT IN ('cancelled', 'failed')
AND oc.orderDate > DATEADD(DD, -366, GETDATE())
AND op.GBSCOMPANYID LIKE 'RM%'
GROUP BY oc.customerID, oc.email, cte.totalRev, cte.orderNo
HAVING COUNT(oc.customerID) > 9
ORDER BY COUNT(oc.customerID) DESC

----**************************
--YOY Rev
;WITH CTE
AS
(SELECT o.customerID,
SUM(ISNULL(o.calcOrderTotal, o.orderTotal)) AS 'revenue_YOY'
FROM tblOrders o
WHERE o.orderDate BETWEEN DATEADD(DD, -731, GETDATE()) AND DATEADD(DD, -366, GETDATE())
AND EXISTS
       (SELECT TOP 1 1
       FROM #reportTopCustomers r
       WHERE o.customerID = r.customerID)
GROUP BY o.customerID)

UPDATE r
SET revenue_YOY = CTE.revenue_YOY
FROM #reportTopCustomers r
INNER JOIN CTE ON r.customerID = CTE.customerID
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID

UPDATE r
SET revenue_YOY = 0
FROM #reportTopCustomers r 
WHERE revenue_YOY IS NULL

----**************************
--last orderDate per customerID
IF OBJECT_ID('tempdb..#tempLastOrder') IS NOT NULL
DROP TABLE #tempLastOrder
CREATE TABLE #tempLastOrder 
       (
       rowID INT IDENTITY(1, 1), 
        customerID INT
       )
DECLARE @NumberRecords INT, 
             @RowCount INT,
             @customerID INT,
             @lastOrderDate DATETIME

INSERT INTO #tempLastOrder (customerID)
SELECT r.customerID
FROM #reportTopCustomers r

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
       SELECT @customerID = customerID
       FROM #tempLastOrder
       WHERE rowID = @RowCount

       SET @lastOrderDate = (SELECT TOP 1 oc.orderDate
                                               FROM #tempJF_OC oc
                                               WHERE @customerID = oc.customerID
                                               ORDER BY oc.orderDate DESC)

       UPDATE #reportTopCustomers
       SET lastOrderDate = @lastOrderDate
       WHERE customerID = @customerID    

       SET @RowCount = @RowCount + 1
END

----**************************
--monthly billing
UPDATE r
SET MonthlyBilling = 1
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID
INNER JOIN tblOrders o ON oc.orderID = o.orderID
WHERE o.paymentMethod = 'Monthly Billing'

----**************************
--get date counts per customerID
DECLARE @DateCount_lessThan30 INT,
             @DateCount_between31and60 INT,
             @DateCount_between61and90 INT,
             @DateCount_between91and365 INT

SET @NumberRecords = 0
SET    @RowCount = 0
SET    @customerID = 0

TRUNCATE TABLE #tempLastOrder
INSERT INTO #tempLastOrder (customerID)
SELECT r.customerID
FROM #reportTopCustomers r

SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

WHILE @RowCount <= @NumberRecords
BEGIN
       SELECT @customerID = customerID
       FROM #tempLastOrder
       WHERE rowID = @RowCount

       SET @DateCount_lessThan30 = (SELECT COUNT(orderID)
                                                     FROM #tempJF_OC oc
                                                     WHERE @customerID = oc.customerID
                                                     AND oc.orderDate BETWEEN DATEADD(DD, -30, GETDATE()) AND GETDATE())

       SET @DateCount_between31and60 = (SELECT COUNT(orderID)
                                                            FROM #tempJF_OC oc
                                                            WHERE @customerID = oc.customerID
                                                            AND oc.orderDate BETWEEN DATEADD(DD, -60, GETDATE()) AND DATEADD(DD, -31, GETDATE()))

       SET @DateCount_between61and90 = (SELECT COUNT(orderID)
                                                            FROM #tempJF_OC oc
                                                            WHERE @customerID = oc.customerID
                                                            AND oc.orderDate BETWEEN DATEADD(DD, -90, GETDATE()) AND DATEADD(DD, -61, GETDATE()))

       SET @DateCount_between91and365 = (SELECT COUNT(orderID)
                                                            FROM #tempJF_OC oc
                                                            WHERE @customerID = oc.customerID
                                                            AND oc.orderDate BETWEEN DATEADD(DD, -365, GETDATE()) AND DATEADD(DD, -91, GETDATE()))

       UPDATE #reportTopCustomers
       SET lessThan30 = ISNULL(@DateCount_lessThan30, 0),
             between31and60 = ISNULL(@DateCount_between31and60, 0),
             between61and90 = ISNULL(@DateCount_between61and90, 0),
             between91and365 = ISNULL(@DateCount_between91and365, 0),
             numOrders_last365 = ISNULL(@DateCount_lessThan30, 0) + ISNULL(@DateCount_between31and60, 0) + ISNULL(@DateCount_between61and90, 0) + ISNULL(@DateCount_between91and365, 0),
             avgOrdersPerMonth = (ISNULL(@DateCount_lessThan30, 0) + ISNULL(@DateCount_between31and60, 0) + ISNULL(@DateCount_between61and90, 0) + ISNULL(@DateCount_between91and365, 0))/12
       WHERE customerID = @customerID    

       SET @RowCount = @RowCount + 1
END

----**************************
-- get MCIDs
IF OBJECT_ID('tempdb..#tempJF_MCID') IS NOT NULL
DROP TABLE #tempJF_MCID

CREATE TABLE #tempJF_MCID(
       CustomerID INT NOT NULL,
       MCID VARCHAR (MAX),
	   MCName VARCHAR (MAX)	   
	   )

INSERT INTO #tempJF_MCID (CustomerID, MCID, MCName)
SELECT DISTINCT o.customerID, 
STUFF((SELECT DISTINCT ', ' + textValue
          FROM tblOrdersProducts_productOptions oppz
          INNER JOIN tblOrders_Products opp ON oppz.ordersProductsID = opp.ID
          INNER JOIN tblOrders oo ON opp.orderID = oo.orderID
          WHERE o.customerID = oo.customerID
          AND oppz.optionCaption = '10 Digit Company Code'
          AND oo.orderStatus NOT IN ('failed', 'cancelled')
		  AND opp.GBSCOMPANYID LIKE 'RM%'
          AND oppz.deleteX <> 'yes'
          AND opp.deleteX <> 'yes'
          FOR XML PATH('')), 1, 1, '') AS MCID
,STUFF((SELECT DISTINCT ', ' + cl.CompanyName
          FROM tblOrdersProducts_productOptions oppz
          INNER JOIN tblOrders_Products opp ON oppz.ordersProductsID = opp.ID
          INNER JOIN tblOrders oo ON opp.orderID = oo.orderID
		  INNER JOIN dbo.CompanyList cl ON cl.GbsCompanyId=oppz.textValue
          WHERE o.customerID = oo.customerID
          AND oppz.optionCaption = '10 Digit Company Code'
          AND oo.orderStatus NOT IN ('failed', 'cancelled')
		  AND opp.GBSCOMPANYID LIKE 'RM%'
          AND oppz.deleteX <> 'yes'
          AND opp.deleteX <> 'yes'
          FOR XML PATH('')), 1, 1, '') AS MCName
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
INNER JOIN #reportTopCustomers r ON o.customerID = r.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND op.deleteX <> 'yes'
AND oppx.optionCaption = '10 Digit Company Code'
AND oppx.deleteX <> 'yes'
AND op.GBSCOMPANYID LIKE 'RM%'
GROUP BY o.customerID

UPDATE r
SET MCID = left(j.MCID,255)
	,MCName = left(j.MCName,255)
FROM #reportTopCustomers r
INNER JOIN #tempJF_MCID j ON r.customerID = j.customerID

UPDATE r
SET parentID = cl.parentGBSCompanyID
FROM #reportTopCustomers r
INNER JOIN #tempJF_MCID j ON r.customerID = j.customerID
INNER JOIN CompanyList cl ON r.MCID = cl.GBSCompanyID

----**************************
-- products purchased by customerID trailing 365

--Business Cards
;WITH CTE
AS
(SELECT DISTINCT r.customerID
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'BP')

UPDATE r
SET BP_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.customerID = CTE.customerID

--Name Badges
;WITH CTE
AS
(SELECT DISTINCT r.customerID
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'NB')

UPDATE r
SET NB_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.customerID = CTE.customerID

--Car Magnets
;WITH CTE
AS
(SELECT DISTINCT r.customerID
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'CM')

UPDATE r
SET CM_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.customerID = CTE.customerID

--Signs
;WITH CTE
AS
(SELECT DISTINCT r.customerID
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'SN')

UPDATE r
SET SN_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.customerID = CTE.customerID

--Apparel
;WITH CTE
AS
(SELECT DISTINCT r.customerID
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'AP')

UPDATE r
SET AP_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.customerID = CTE.customerID

--Notecards
;WITH CTE
AS
(SELECT DISTINCT r.customerID
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'NC')

UPDATE r
SET NC_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.customerID = CTE.customerID

--Folders
;WITH CTE
AS
(SELECT DISTINCT r.customerID
FROM #reportTopCustomers r
INNER JOIN #tempJF_OC oc ON r.customerID = oc.customerID
INNER JOIN #tempJF_OP op ON oc.orderID = op.orderID
WHERE LEFT(op.productCode, 2) = 'FD')

UPDATE r
SET FD_last365 = 1
FROM #reportTopCustomers r
INNER JOIN CTE ON r.customerID = CTE.customerID

----**************************
-- update new columns

UPDATE r
SET phone = c.phone,
	firstName = c.firstName,
	surName = c.surName
FROM #reportTopCustomers r
INNER JOIN tblCustomers c ON r.customerID = c.customerID

UPDATE r
SET orderDate = o.orderDate,
	calcOrderTotal = o.calcOrderTotal,
	orderStatus = o.orderStatus
FROM #reportTopCustomers r
INNER JOIN tblOrders o ON r.orderNo = o.orderNo

UPDATE r
SET shipping_company = s.shipping_company,
	shipping_fullName = s.shipping_fullName,
	shipping_street	 = s.shipping_street,
	shipping_street2 = s.shipping_street2,
	shipping_suburb = s.shipping_suburb,
	shipping_state = s.shipping_state,
	shipping_postcode = s.shipping_postcode
FROM #reportTopCustomers r
INNER JOIN tblCustomers_ShippingAddress s ON r.orderNo = s.orderNo

----**************************
-- get data
SELECT * FROM #reportTopCustomers
ORDER BY numOrders_last365 DESC