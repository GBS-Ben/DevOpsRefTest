CREATE PROCEDURE [dbo].[Report_L10Monthly]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     01/02/2022
Purpose     Pulls monthly numbers for L10
-------------------------------------------------------------------------------
Modification History

01/02/2022		New

-------------------------------------------------------------------------------
*/

--VARIABLES:
DECLARE @END DATETIME = '20220201'         -- 12/01/2021 -- 01/01/2022 -- 02/01/2022
DECLARE @BEGIN_MONTH DATETIME = '20220101' -- 11/01/2021 -- 12/01/2021 -- 01/01/2022
DECLARE @BEGIN12MT DATETIME = '20210201'   -- 12/01/2020 -- 01/01/2021 -- 02/01/2021
DECLARE @BEGIN24MT DATETIME = '20200201'   -- 12/01/2019 -- 01/01/2020 -- 02/01/2020
DECLARE @CT NUMERIC (8,2)
DECLARE @CONV_VALUE INT
DECLARE @GA INT = 44699 --Comes from Audience Overview in GA
DECLARE @SHOPSALES MONEY
DECLARE @NON_SHOPSALES MONEY
DECLARE @SHOPCUSTOMERS MONEY
DECLARE @NON_SHOPCUSTOMERS MONEY
DECLARE @disEmail INT
DECLARE @disOrder INT
DECLARE @SHOP_OPIDS MONEY
DECLARE @NON_SHOPOPIDS MONEY

----Website Conversion Rate (HOM/MRK) (Monthly) -----------------------------------------------------------
--@VALUE
SET @CONV_VALUE = (SELECT COUNT(DISTINCT(orderID))
					FROM tblOrders o
					WHERE o.orderStatus NOT IN ('failed', 'cancelled')
					AND o.orderDate BETWEEN @BEGIN_MONTH AND @END
					AND LEFT(o.orderNo, 3) IN ('HOM', 'MRK'))

SELECT (CONVERT(DEC(8,2),@CONV_VALUE)/CONVERT(DEC(8,2), @GA)) * 100 AS 'Website Conversion Rate (HOM/MRK) (Monthly)'

 --ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS
 --ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS
 --ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS--ORDERS

--Orders - Total Number of Orders (MONTHLY) -------------------------
SELECT COUNT(DISTINCT(orderNo)) AS 'Orders - Total Number of Orders (MONTHLY)'
FROM tblOrders
WHERE orderStatus NOT IN ('failed', 'cancelled')
AND orderDate BETWEEN @BEGIN_MONTH AND @END 
AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK')

--Orders - Total Number of Orders (12MT) -------------------------
SELECT COUNT(DISTINCT(orderNo)) AS 'Orders - Total Number of Orders (12MT)'
FROM tblOrders
WHERE orderStatus NOT IN ('failed', 'cancelled')
AND orderDate BETWEEN @BEGIN12MT AND @END 
AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK')

--Orders - Average Order Value (MONTHLY) -------------------------
SELECT AVG(calcOrderTotal) AS 'Orders - Average Order Value (MONTHLY)'
FROM tblOrders
WHERE orderStatus NOT IN ('failed', 'cancelled')
AND orderDate BETWEEN @BEGIN_MONTH AND @END 
AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK')

--Orders - Average Order Value (12MT) -------------------------
SELECT AVG(calcOrderTotal) AS 'Orders - Average Order Value (12MT)'
FROM tblOrders
WHERE orderStatus NOT IN ('failed', 'cancelled')
AND orderDate BETWEEN @BEGIN12MT AND @END 
AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK')

--PERCENTAGE OF ORDERS OVER X FOR THE GIVEN MONTH -------------------------
SET @CT = (SELECT COUNT(DISTINCT(orderNo))
					FROM tblOrders
					WHERE orderStatus NOT IN ('failed', 'cancelled')
					AND orderDate BETWEEN @BEGIN_MONTH AND @END 
					AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK'))

			--Orders  - % over $100
			SELECT 100*ISNULL(COUNT(DISTINCT(orderNo)), 0)/@CT, '100', 'Over 100'
			FROM tblOrders
			WHERE orderStatus NOT IN ('failed', 'cancelled')
			AND orderDate BETWEEN @BEGIN_MONTH AND @END 
			AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK')
			AND calcOrderTotal >= 100
			UNION
			--Orders  - % over $120
			SELECT 100*ISNULL(COUNT(DISTINCT(orderNo)), 0)/@CT, '120', 'Over 120'
			FROM tblOrders
			WHERE orderStatus NOT IN ('failed', 'cancelled')
			AND orderDate BETWEEN @BEGIN_MONTH AND @END 
			AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK')
			AND calcOrderTotal >= 120
			UNION
			--Orders  - % over $150
			SELECT 100*ISNULL(COUNT(DISTINCT(orderNo)), 0)/@CT, '150', 'Over 150'
			FROM tblOrders
			WHERE orderStatus NOT IN ('failed', 'cancelled')
			AND orderDate BETWEEN @BEGIN_MONTH AND @END 
			AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK')
			AND calcOrderTotal >= 150
			UNION
			--Orders  - % over $200
			SELECT 100*ISNULL(COUNT(DISTINCT(orderNo)), 0)/@CT, '200', 'Over 200'
			FROM tblOrders
			WHERE orderStatus NOT IN ('failed', 'cancelled')
			AND orderDate BETWEEN @BEGIN_MONTH AND @END 
			AND LEFT(orderNo, 3) IN ('HOM', 'NCC', 'MRK')
			AND calcOrderTotal >= 200

---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS
---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS
---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS---SHOPS

--Shops - New Shops Created (Monthly) -------------------------
SELECT YrMo=CONVERT(VARCHAR(4), Year(createdonutc))
            + RIGHT('00' + CONVERT(VARCHAR(2), Month(createdonutc)), 2 ),
       COUNT(*) AS 'Shops - New Shops Created (Monthly)'
FROM   sql01.nopcommerce.dbo.tblcompany -- Also,  could use: [HOMLIVE.dbo.CompanyList]
WHERE  published = 1
       AND deleted = 0
GROUP  BY CONVERT(VARCHAR(4), Year(createdonutc))
          + RIGHT('00' + CONVERT(VARCHAR(2), Month(createdonutc)), 2 )
ORDER  BY CONVERT(VARCHAR(4), Year(createdonutc))
          + RIGHT('00' + CONVERT(VARCHAR(2), Month(createdonutc)), 2 ) DESC 

--Shops - New Shops Activated (Monthly) -------------------------
SELECT COUNT(DISTINCT(op.GBSCompanyID)) AS 'Shops - New Shops Activated (Monthly)'
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderDate BETWEEN @BEGIN_MONTH AND @END
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
AND NOT EXISTS
	(SELECT TOP 1 1 
	FROM tblOrders oo
	INNER JOIN tblOrders_Products opp ON oo.orderID = opp.orderID
	WHERE oo.orderStatus NOT IN ('failed', 'cancelled')
	AND oo.orderDate < @BEGIN_MONTH
	AND LEFT(oo.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
	AND opp.GBSCompanyID = op.GBSCompanyID)

--Shops - Number of Active Shops (12MT) ----------------------------------------
SELECT COUNT(DISTINCT(op.GBSCompanyID)) AS 'Shops - Number of Active Shops (12MT)'
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderDate BETWEEN @BEGIN12MT AND @END
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')

--Shops - Average Annual Value of a Shop (12MT)  ----------------------------------------------------
TRUNCATE TABLE ReportShopAYO
;WITH CTE AS(
		SELECT DISTINCT o.orderid
		FROM tblOrders o
		INNER JOIN tblCustomers c ON o.customerID = c.customerID
		WHERE o.orderStatus NOT IN ('failed', 'cancelled')
		AND o.orderDate BETWEEN @BEGIN12MT AND @END
		AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
		AND EXISTS
			(SELECT TOP 1 1
			FROM tblOrders_Products opx
			WHERE opx.GBSCompanyID IS NOT NULL
			AND o.orderID = opx.orderID))

INSERT INTO ReportShopAYO (ShopAYO)
SELECT SUM(o.calcOrderTotal) AS ShopAYO
FROM tblOrders o
INNER JOIN CTE ON o.orderID = CTE.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderDate BETWEEN @BEGIN12MT AND @END
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')

DECLARE @countActiveShops INT
SET @countActiveShops = (SELECT COUNT(DISTINCT(op.GBSCompanyID))
						FROM tblOrders o
						INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
						WHERE o.orderStatus NOT IN ('failed', 'cancelled')
						AND o.orderDate BETWEEN @BEGIN12MT AND @END
						AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK'))

SELECT ShopAYO/@countActiveShops AS 'Shops - Average Annual Value of a Shop (12MT)'
FROM ReportShopAYO

--Shops - Total Revenue for all Shops (12MT) ----------------------------------------------------
;WITH CTE AS(
		SELECT DISTINCT o.orderid
		FROM tblOrders o
		INNER JOIN tblCustomers c ON o.customerID = c.customerID
		WHERE o.orderStatus NOT IN ('failed', 'cancelled')
		AND o.orderDate BETWEEN @BEGIN12MT AND @END
		AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
		AND EXISTS
			(SELECT TOP 1 1
			FROM tblOrders_Products opx
			WHERE opx.GBSCompanyID IS NOT NULL
			AND o.orderID = opx.orderID))

SELECT SUM(o.calcOrderTotal) AS 'Shops - Total Rev for all Shops (12MT)'
FROM tblOrders o
INNER JOIN CTE ON o.orderID = CTE.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderDate BETWEEN @BEGIN12MT AND @END
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')

--Shops - Percentage of Total Ecomm Revenue (12MT) ----------------------------------------------------
SET @SHOPSALES = (SELECT SUM(o.calcOrderTotal)
				FROM tblOrders o
				WHERE o.orderStatus NOT IN ('failed', 'cancelled')
				AND o.orderDate BETWEEN @BEGIN12MT AND @END
				AND LEFT(o.orderNo, 3)  IN ('HOM', 'NCC', 'MRK', 'ATM', 'ADH')
				AND EXISTS
					(SELECT TOP 1 1
					FROM tblOrders_Products opx
					WHERE opx.GBSCompanyID IS NOT NULL
					AND o.orderID = opx.orderID))

SET @NON_SHOPSALES = (SELECT SUM(o.calcOrderTotal)
					FROM tblOrders o
					WHERE o.orderStatus NOT IN ('failed', 'cancelled')
					AND o.orderDate BETWEEN @BEGIN12MT AND @END
					AND LEFT(o.orderNo, 3)  IN ('HOM', 'NCC', 'MRK', 'ATM', 'ADH')
					AND NOT EXISTS
						(SELECT TOP 1 1
						FROM tblOrders_Products opx
						WHERE opx.GBSCompanyID IS NOT NULL
						AND o.orderID = opx.orderID))

SELECT CONVERT(DEC(8,4),(@SHOPSALES/(@SHOPSALES + @NON_SHOPSALES))) * 100 AS 'Shops - Percentage of Total Ecomm Revenue (12MT)'


--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER
--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER
--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER--CUSTOMER

--Customers - Percentage of Distinct Customers that ordered from a Shop (12MT) ---------------------------------------------------
SET @SHOPCUSTOMERS = (SELECT COUNT(DISTINCT(customerID))
				FROM tblOrders o
				WHERE o.orderStatus NOT IN ('failed', 'cancelled')
				AND o.orderDate BETWEEN @BEGIN12MT AND @END
				AND LEFT(o.orderNo, 3)  IN ('HOM', 'NCC', 'MRK', 'ATM', 'ADH')
				AND EXISTS
					(SELECT TOP 1 1
					FROM tblOrders_Products opx
					INNER JOIN tblOrders ox ON opx.orderid = ox.orderID
					WHERE opx.GBSCompanyID IS NOT NULL
					AND o.customerID = ox.customerID))

SET @NON_SHOPCUSTOMERS = (SELECT COUNT(DISTINCT(customerID))
					FROM tblOrders o
					WHERE o.orderStatus NOT IN ('failed', 'cancelled')
					AND o.orderDate BETWEEN @BEGIN12MT AND @END
					AND LEFT(o.orderNo, 3)  IN ('HOM', 'NCC', 'MRK', 'ATM', 'ADH')
					AND NOT EXISTS
						(SELECT TOP 1 1
						FROM tblOrders_Products opx
						INNER JOIN tblOrders ox ON opx.orderid = ox.orderID
						WHERE opx.GBSCompanyID IS NOT NULL
						AND o.customerID = ox.customerID))

SELECT CONVERT(DEC(8,4),(@SHOPCUSTOMERS/(@SHOPCUSTOMERS + @NON_SHOPCUSTOMERS))) * 100 AS 'Customers - Percentage of Distinct Customers that ordered from a Shop (12MT)'

--Customers - Average Yearly Orders per Customer (12MT) ----------------------------------------------------
SET @disEmail = (SELECT COUNT(DISTINCT(c.email))
FROM tblOrders o
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderDate BETWEEN @BEGIN12MT AND @END
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK'))

SET @disOrder = (SELECT COUNT(DISTINCT(o.orderID))
FROM tblOrders o
WHERE o.orderDate BETWEEN @BEGIN12MT AND @END
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK'))

--# of orders per customer per year
SELECT (CONVERT(DEC(8,2),@disOrder)/CONVERT(DEC(8,2),@disEmail)) AS 'Customers - Average Yearly Orders per Customer (12MT)'

--Customers - Average Yearly Value per Customer (12MT) ----------------------------------------------------
;WITH CTE AS(
			SELECT SUM(o.calcOrderTotal) AS sumTotal , c.email AS email, COUNT(c.email) AS emailCount
			FROM tblOrders o
			INNER JOIN tblCustomers c ON o.customerID = c.customerID
			WHERE o.orderDate BETWEEN @BEGIN12MT AND @END
			AND o.orderStatus NOT IN ('failed', 'cancelled')
			AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
			GROUP BY c.email)

SELECT AVG(CTE.sumTotal) AS 'Customers - Average Yearly Value per Customer (12MT)'
FROM CTE

--Customers - Number of Unique Customers (12MT) ----------------------------------------------------
SELECT COUNT(DISTINCT(c.email)) AS 'Customers - Number of Unique Customers (12MT)'
FROM tblOrders o
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderDate BETWEEN @BEGIN12MT AND @END
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')

--Customers - Number Acquired (12MT) ----------------------------------------------------------------
SELECT COUNT(DISTINCT(c.email)) AS 'Customers - Number Acquired (12MT)'
FROM tblOrders o
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderDate BETWEEN @BEGIN12MT AND @END
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
AND NOT EXISTS
	(SELECT TOP 1 1 
	FROM tblOrders oo
	INNER JOIN tblCustomers cc ON oo.customerID = cc.customerID
	WHERE oo.orderStatus NOT IN ('failed', 'cancelled')
	AND oo.orderDate < @BEGIN12MT
	AND LEFT(oo.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
	AND c.customerID = cc.customerID)

--Customers - Number of Non-Returning Customers (12MT) ----------------------------------------------------
;WITH CTE AS(
			SELECT DISTINCT(c.email) AS disEmail
			FROM tblOrders o
			INNER JOIN tblCustomers c ON o.customerID = c.customerID
			WHERE o.orderDate BETWEEN @BEGIN12MT AND @END
			AND o.orderStatus NOT IN ('failed', 'cancelled')
			AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK'))

SELECT COUNT(DISTINCT(c.email)) AS 'Customers - Number of Non-Returning Customers (12MT)'
FROM tblOrders o
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderDate BETWEEN @BEGIN24MT AND @BEGIN12MT
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
AND NOT EXISTS
	(SELECT TOP 1 1
	FROM CTE
	WHERE CTE.disEmail = c.email)

--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS
--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS
--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS--PRODUCTS

--Products - Number of Unique Product Types per Order (Monthly) ----------------------------------------------------
TRUNCATE TABLE ReportProductMix
INSERT INTO ReportProductMix (orderID)
SELECT DISTINCT orderID
FROM tblOrders o
WHERE o.orderDate BETWEEN @BEGIN_MONTH AND @END
AND o.orderStatus NOT IN ('failed', 'cancelled')
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')

UPDATE x SET BP = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'BP'
UPDATE x SET QC = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'QC'
UPDATE x SET QS = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'QS'
UPDATE x SET QM = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'QM'
UPDATE x SET FC = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'FC'
UPDATE x SET JU = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'JU'
UPDATE x SET EX = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'EX'
UPDATE x SET BU = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'BU'
UPDATE x SET [IN] = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'IN'
UPDATE x SET FD = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'FD'
UPDATE x SET EV = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE (LEFT(op.productCode, 2) = 'EV' OR SUBSTRING(op.productCode, 3, 2) = 'EV') AND op.productName LIKE '%envelope%'
UPDATE x SET NP = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE (LEFT(op.productCode, 2) = 'GN' OR LEFT(op.productCode, 6) = 'FANCV1') AND op.productName  LIKE '%notepad%'
UPDATE x SET DK = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'DK'
UPDATE x SET SN = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'SN'
UPDATE x SET AP = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'AP'
UPDATE x SET NB = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'NB'
UPDATE x SET CM = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE (LEFT(op.productCode, 2) = 'CM' OR SUBSTRING(op.productCode, 3, 2) = 'CM') AND op.productName LIKE '%car magnet%'
UPDATE x SET AW = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'AW'
UPDATE x SET PM = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'PM'
UPDATE x SET PL = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'PL'
UPDATE x SET NC = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'NC'
UPDATE x SET CA = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'CA'
UPDATE x SET LP = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'LP'
UPDATE x SET BM = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'BM'
UPDATE x SET MK = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'MK'
UPDATE x SET PN = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'PN'
UPDATE x SET MC = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 6) = 'MC00SU'
UPDATE x SET [PI] = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'PI'
UPDATE x SET LH = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'LH'
UPDATE x SET WP = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'WP'
UPDATE x SET ES = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE (LEFT(op.productCode, 2) = 'ES' OR SUBSTRING(op.productCode, 3, 2) = 'ES') AND op.productName LIKE '%seal%'
UPDATE x SET ST = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'ST'
UPDATE x SET PP = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'PP'
UPDATE x SET CH = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 1, 4) = 'KWCH'
UPDATE x SET TF = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'TF'
UPDATE x SET LB = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'LB'
UPDATE x SET MU = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'MU'
UPDATE x SET PH = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'PH'
UPDATE x SET SK = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'SK'
UPDATE x SET LK = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'LK'
UPDATE x SET PA = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'PA'
UPDATE x SET DC = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE LEFT(op.productCode, 2) = 'DC'
UPDATE x SET FB = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'FB'
UPDATE x SET HM = 1 FROM ReportProductMix x INNER JOIN tblOrders_Products op ON x.orderID = op.orderID WHERE SUBSTRING(op.productCode, 3, 2) = 'HM'

--update sumUnique
UPDATE ReportProductMix SET sumUnique = bp + qc + qs + qm + fc + ju + ex + bu + [in] + fd + ev + np + dk + sn + ap + nb + cm + aw + pm + pl + nc + ca + lp + bm + mk + pn + mc + [pi] + lh + wp + es + st + pp + ch + tf + lb + mu + ph + sk + pa + lk + dc + fb + hm

--get the avg
SELECT AVG(CONVERT(DEC(8,2), sumUnique)) AS 'Products - Number of Unique Product Types per Order (Monthly) '
FROM ReportProductMix --1.720896

/*
--check for zeroes in the data
SELECT productcode, * FROM tblorders_products where orderid in (
SELECT orderid FROM ReportProductMix WHERE bp = 0 AND qc = 0 AND qs = 0 AND qm = 0 AND fc = 0 AND ju = 0 AND ex = 0 AND bu = 0 AND [in] = 0 AND fd = 0 AND ev = 0 AND np = 0 AND dk = 0 AND sn = 0 AND ap = 0 AND nb = 0 AND cm = 0 AND aw = 0 AND pm = 0 AND nc = 0 AND pl = 0 AND ca = 0 AND lp = 0 AND bm = 0 AND mk = 0 AND pn = 0 AND mc = 0 AND [pi] = 0 AND lh = 0 AND wp = 0 AND es = 0 AND st = 0 AND pp = 0 AND ch = 0 AND tf = 0 and lb = 0 and mu = 0 and ph = 0 and sk = 0 AND pa = 0 AND lk = 0 AND dc = 0 AND fb = 0 AND hm = 0
) order by 1
*/

--Products - % of Total OPIDs Purchased from a Shop (12MT) ---------------------------------------------------

--@SHOP_OPIDS
SET @SHOP_OPIDS = (SELECT COUNT(DISTINCT(op.ID))
					FROM tblOrders_Products op
					INNER JOIN tblOrders o ON o.orderid = op.orderid
					WHERE o.orderStatus NOT IN ('failed', 'cancelled')
					AND o.orderDate BETWEEN @BEGIN12MT AND @END
					AND LEFT(o.orderNo, 3)  IN ('HOM', 'NCC', 'MRK', 'ATM', 'ADH')
					AND op.GBSCompanyID IS NOT NULL)

--@NON_SHOPOPIDS
SET @NON_SHOPOPIDS = (SELECT COUNT(DISTINCT(op.ID))
					FROM tblOrders_Products op
					INNER JOIN tblOrders o ON o.orderid = op.orderid
					WHERE o.orderStatus NOT IN ('failed', 'cancelled')
					AND o.orderDate BETWEEN @BEGIN12MT AND @END
					AND LEFT(o.orderNo, 3)  IN ('HOM', 'NCC', 'MRK', 'ATM', 'ADH')
					AND op.GBSCompanyID IS NULL)

SELECT CONVERT(DEC(8,4),(@SHOP_OPIDS/(@SHOP_OPIDS + @NON_SHOPOPIDS))) * 100 AS 'Products - % of Total OPIDs Purchased from a Shop (12MT)'