CREATE PROC [dbo].[RPT_FTDMAJF]
AS

/*
Jeremy's reports for CG

FIND/REPLACE: 2017 with 2020, for example.
Or, for last 365, replace with appropriate DATEDIFF operation.


Report requests:

Units of measure:
	(A) SubTotal
			ignore: tax, shipping and coupon/vouchers
			include: roll up OPPOs 
	(B) # of Orders
	(C) # of Customers
--------------------------------------------------------------------------------------------------------
1. ABC by Product
	BP and other product lines
	FBFC, and other seasonal breakouts

2. ABC by Market Center
		Use tblCompany and op.GBSCompanyID
		Rollup would be great to have as well
		Not Exact

3. Customer breakdown
		How many are new in last 365  xxx
			by email
		AOV xxx
			average order value over the past year
		AOY xxx
			average orders per year/ per customer
*/
--1. PRODUCTS--###########################################################################################################################################################

-- TOTAL SALES -------------------------------- *******
SELECT 'Business Cards' AS productType, ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'BP%'
UNION
SELECT 'Name badges', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'NB%'
UNION
SELECT 'CACH', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACH%'
UNION
SELECT 'CACP', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACP%'
UNION
SELECT 'CACC', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACC%'
UNION
SELECT 'Notecards', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'NC%'
UNION
SELECT 'Signs', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'SN%'
UNION
SELECT 'Pens', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'PN%'
UNION
SELECT 'First Class Magnets', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'FC'
UNION
SELECT 'Quick Cards', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'QC'
UNION
SELECT 'Quick Magnets', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'QM'
UNION
SELECT 'Car Magnets', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CM%'
UNION
SELECT 'Budget Magnets', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'BU'
UNION
SELECT 'Executive Magnets', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'EX'
UNION
SELECT 'Jumbo Magnets', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'JU'
UNION
SELECT 'Postcard Mailers', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'PM'
UNION
SELECT 'Inserts', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'IN'
UNION
SELECT 'Calendars', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'CA'
UNION
SELECT 'Football', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'FB'
UNION
SELECT 'Baseball', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'BB'
UNION
SELECT 'Basketball', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'BK'
UNION
SELECT 'Hockey', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'HY'
UNION
SELECT 'Golf', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'PG'
UNION
SELECT 'Apparel', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'AP'
UNION
SELECT 'Sealers', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'ES'
UNION
SELECT 'Masks', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 4) =  'MKFM'
UNION
SELECT 'Gaiters', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 4) =  'MKNG'
UNION
SELECT 'Nameplates', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'PL'
UNION
SELECT 'Whiteboards', ROUND(SUM(op.productQuantity * op.productPrice),2) AS productTotal
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'WB'

-- TOTAL ORDERS -------------------------------- *******
SELECT 'Business Cards' AS productType, COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'BP%'
UNION
SELECT 'Name badges', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'NB%'
UNION
SELECT 'CACH', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACH%'
UNION
SELECT 'CACP', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACP%'
UNION
SELECT 'CACC', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACC%'
UNION
SELECT 'Notecards', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'NC%'
UNION
SELECT 'Signs', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'SN%'
UNION
SELECT 'Pens', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'PN%'
UNION
SELECT 'First Class Magnets', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'FC'
UNION
SELECT 'Quick Cards', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'QC'
UNION
SELECT 'Quick Magnets', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'QM'
UNION
SELECT 'Car Magnets', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CM%'
UNION
SELECT 'Budget Magnets', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'BU'
UNION
SELECT 'Executive Magnets', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'EX'
UNION
SELECT 'Jumbo Magnets', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'JU'
UNION
SELECT 'Postcard Mailers', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'PM'
UNION
SELECT 'Inserts', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'IN'
UNION
SELECT 'Calendars', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'CA'
UNION
SELECT 'Football', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'FB'
UNION
SELECT 'Baseball', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'BB'
UNION
SELECT 'Basketball', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'BK'
UNION
SELECT 'Hockey', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'HY'
UNION
SELECT 'Golf', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'PG'
UNION
SELECT 'Apparel', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'AP'
UNION
SELECT 'Sealers', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'ES'
UNION
SELECT 'Masks', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 4) =  'MKFM'
UNION
SELECT 'Gaiters', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 4) =  'MKNG'
UNION
SELECT 'Nameplates', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'PL'
UNION
SELECT 'Whiteboards', COUNT(o.orderID) AS TotalOrders
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'WB'

-- TOTAL UNITS SOLD -------------------------------- *******
SELECT 'Business Cards' AS productType, SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'BP%'
UNION
SELECT 'Name badges', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'NB%'
UNION
SELECT 'CACH', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACH%'
UNION
SELECT 'CACP', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACP%'
UNION
SELECT 'CACC', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CACC%'
UNION
SELECT 'Notecards', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'NC%'
UNION
SELECT 'Signs', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'SN%'
UNION
SELECT 'Pens', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'PN%'
UNION
SELECT 'First Class Magnets', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'FC'
UNION
SELECT 'Quick Cards', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'QC'
UNION
SELECT 'Quick Magnets', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) = 'QM'
UNION
SELECT 'Car Magnets', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND op.productCode LIKE 'CM%'
UNION
SELECT 'Budget Magnets', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'BU'
UNION
SELECT 'Executive Magnets', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'EX'
UNION
SELECT 'Jumbo Magnets', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'JU'
UNION
SELECT 'Postcard Mailers', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'PM'
UNION
SELECT 'Inserts', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 3, 2) =  'IN'
UNION
SELECT 'Calendars', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'CA'
UNION
SELECT 'Football', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'FB'
UNION
SELECT 'Baseball', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'BB'
UNION
SELECT 'Basketball', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'BK'
UNION
SELECT 'Hockey', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'HY'
UNION
SELECT 'Golf', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'PG'
UNION
SELECT 'Apparel', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'AP'
UNION
SELECT 'Sealers', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'ES'
UNION
SELECT 'Masks', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 4) =  'MKFM'
UNION
SELECT 'Gaiters', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 4) =  'MKNG'
UNION
SELECT 'Nameplates', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'PL'
UNION
SELECT 'Whiteboards', SUM(op.productQuantity) AS TotalUnitsSold
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND SUBSTRING(op.productCode, 1, 2) =  'WB'
--2. MARKET CENTER--######################################################################################################################################################
--tblCompany seems to be more accurate than companyList, and furthermore, it has the parent roll up data that we need.
--SELECT * FROM companylist WHERE gbscompanyID NOT IN (SELECT gbscompanyid from tblcompany) --0
--SELECT * FROM tblcompany  WHERE gbscompanyID NOT IN (SELECT gbscompanyid from companylist) --1587 (SHOULD BE ZERO BEFORE RUNNING CODE BELOW)

--HAVE TO RUN THIS TO CATCH EVERYTHING UP:
INSERT INTO companyList (GBSCompanyID, CompanyName, ParentGBSCompanyID)
SELECT GBSCompanyID, [Name], ParentCompanyID
FROM tblCompany
WHERE gbscompanyID NOT IN (SELECT gbscompanyid from companylist) 

-- TOTAL SALES -------------------------------- *******
--MC LEVEL: (A1) Total Sales per Office
;WITH CTE AS(
SELECT DISTINCT x.GBSCompanyID, x.CompanyName, o.calcProducts + o.calcOPPO AS SubTotal
FROM tblOrders_Products op
INNER JOIN tblOrders o ON o.orderID = op.orderID
INNER JOIN companyList x ON x.GBSCompanyID = op.GBSCompanyID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND x.GBSCompanyID <> 'FA-100-00000'
GROUP BY x.GBSCompanyID, x.CompanyName, o.calcProducts, o.calcOPPO)

SELECT CTE.GBSCompanyID, CTE.CompanyName, ROUND(SUM(CTE.SubTotal),2) AS TotalSales_PerOffice
FROM CTE
GROUP BY CTE.GBSCompanyID, CTE.CompanyName
ORDER BY 3 DESC

--MC LEVEL: (A2) Total Sales Rolled up to Parent
;WITH CTE AS(
SELECT DISTINCT x.GBSCompanyID, x.CompanyName, o.calcProducts + o.calcOPPO AS SubTotal
FROM tblOrders_Products op
INNER JOIN tblOrders o ON o.orderID = op.orderID
INNER JOIN companyList x ON x.GBSCompanyID = op.GBSCompanyID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND x.GBSCompanyID <> 'FA-100-00000'
GROUP BY x.GBSCompanyID, x.CompanyName, o.calcProducts, o.calcOPPO)

SELECT x.ParentGBSCompanyID, xx.CompanyName, ROUND(SUM(CTE.SubTotal),2) AS TotalSales_PerParent
FROM CTE 
INNER JOIN companyList x ON x.GBSCompanyID = CTE.GBSCompanyID
INNER JOIN companyList xx ON x.ParentGBSCompanyID = xx.GBSCompanyID
GROUP BY x.ParentGBSCompanyID, xx.CompanyName
ORDER BY 3 DESC

-- ORDER COUNT --------------------------------*******
--MC LEVEL: (B1) Total Order Count per Office
;WITH CTE AS(
SELECT DISTINCT x.GBSCompanyID, x.CompanyName, COUNT(o.orderID) AS OrderCount
FROM tblOrders_Products op
INNER JOIN tblOrders o ON o.orderID = op.orderID
INNER JOIN companyList x ON x.GBSCompanyID = op.GBSCompanyID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND x.GBSCompanyID <> 'FA-100-00000'
GROUP BY x.GBSCompanyID, x.CompanyName, o.calcProducts, o.calcOPPO)

SELECT CTE.GBSCompanyID, CTE.CompanyName, SUM(CTE.OrderCount) AS OrderCount_PerOffice
FROM CTE
GROUP BY CTE.GBSCompanyID, CTE.CompanyName
ORDER BY 3 DESC

--MC LEVEL: (B2) Total Order Count Rolled up to Parent
;WITH CTE AS(
SELECT DISTINCT x.GBSCompanyID, x.CompanyName, COUNT(o.orderID) AS OrderCount
FROM tblOrders_Products op
INNER JOIN tblOrders o ON o.orderID = op.orderID
INNER JOIN companyList x ON x.GBSCompanyID = op.GBSCompanyID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND x.GBSCompanyID <> 'FA-100-00000'
GROUP BY x.GBSCompanyID, x.CompanyName, o.calcProducts, o.calcOPPO)

SELECT x.ParentGBSCompanyID, xx.CompanyName, SUM(CTE.OrderCount) AS OrderCount_PerParent
FROM CTE 
INNER JOIN companyList x ON x.GBSCompanyID = CTE.GBSCompanyID
INNER JOIN companyList xx ON x.ParentGBSCompanyID = xx.GBSCompanyID
GROUP BY x.ParentGBSCompanyID, xx.CompanyName
ORDER BY 3 DESC

-- CUSTOMER COUNT --------------------------------*******
--MC LEVEL: (C1) Total Customer Count per Office
;WITH CTE AS(
SELECT DISTINCT x.GBSCompanyID, x.CompanyName, COUNT(DISTINCT(c.email)) AS CustomerCount
FROM tblOrders_Products op
INNER JOIN tblOrders o ON o.orderID = op.orderID
INNER JOIN companyList x ON x.GBSCompanyID = op.GBSCompanyID
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND x.GBSCompanyID <> 'FA-100-00000'
GROUP BY x.GBSCompanyID, x.CompanyName, o.calcProducts, o.calcOPPO)

SELECT CTE.GBSCompanyID, CTE.CompanyName, SUM(CTE.CustomerCount) AS CustomerCount_PerOffice
FROM CTE
GROUP BY CTE.GBSCompanyID, CTE.CompanyName
ORDER BY 3 DESC

--MC LEVEL: (C2) Customer Count Rolled up to Parent
;WITH CTE AS(
SELECT DISTINCT x.GBSCompanyID, x.CompanyName, COUNT(DISTINCT(c.email)) AS CustomerCount
FROM tblOrders_Products op
INNER JOIN tblOrders o ON o.orderID = op.orderID
INNER JOIN companyList x ON x.GBSCompanyID = op.GBSCompanyID
INNER JOIN tblCustomers c ON o.customerID = c.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND op.deleteX <> 'yes'
AND x.GBSCompanyID <> 'FA-100-00000'
GROUP BY x.GBSCompanyID, x.CompanyName, o.calcProducts, o.calcOPPO)

SELECT x.ParentGBSCompanyID, xx.CompanyName, SUM(CTE.CustomerCount) AS CustomerCount_PerParent
FROM CTE 
INNER JOIN companyList x ON x.GBSCompanyID = CTE.GBSCompanyID
INNER JOIN companyList xx ON x.ParentGBSCompanyID = xx.GBSCompanyID
GROUP BY x.ParentGBSCompanyID, xx.CompanyName
ORDER BY 3 DESC

--3.CUSTOMER BREAKDOWN  --###############################################################################################################################################
--HOW MANY NEW CUSTOMERS IN 2017 THAT HAD NOT ORDERED IN PREVIOUS (OR SUBSEQUENT) YEARS?------------------------------------

SELECT COUNT(DISTINCT(EMAIL))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
AND NOT EXISTS
	(SELECT TOP 1 1 
	FROM tblCustomers cc
	INNER JOIN tblOrders oo ON cc.customerID = oo.customerID
	WHERE oo.orderStatus NOT IN ('failed', 'cancelled')
	AND DATEPART(YY, oo.orderDate) NOT IN ('2017')
	AND c.email = cc.email) --46,412

--WHAT WAS THE AVERAGE ORDER TOTAL IN 2017? --------------------------------------------------------------------------------

SELECT AVG(o.calcProducts + o.calcOPPO)
FROM tblOrders o
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017' --90.7901

--HOW MANY ORDERS DO OUR CUSTOMERS AVERAGE PER YEAR?----------------------------------------------------------------------------

DECLARE @YR CHAR(4) 
SET @YR = '2017'

DECLARE @ctEmail DECIMAL (10,3)
SET @ctEmail = (
SELECT COUNT(DISTINCT(c.email))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = @YR) --76040

DECLARE @ctOrder DECIMAL (10,3)
SET @ctOrder = (
SELECT COUNT(DISTINCT(o.orderNo))
FROM tblOrders o
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = @YR) --123330

--PRINT @ctOrder
--PRINT @ctEmail
SELECT @YR, @ctOrder/@ctEmail --1.622 Orders Per Customer, Per Year.


--HOW MANY CUSTOMERS DO WE HAVE FOR THE YEAR IN QUESTION-------------------------------------------------------------------------


SELECT '2017', COUNT(DISTINCT(EMAIL))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
UNION
SELECT '2018', COUNT(DISTINCT(EMAIL))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2018'
UNION
SELECT '2019', COUNT(DISTINCT(EMAIL))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2019'
UNION
SELECT '2020', COUNT(DISTINCT(EMAIL))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2020'


SELECT '2017 - by customerID', COUNT(DISTINCT(o.customerid))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2017'
UNION
SELECT '2018 - by customerID', COUNT(DISTINCT(o.customerid))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerid = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2018'
UNION
SELECT '2019 - by customerID', COUNT(DISTINCT(o.customerid))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerid = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2019'
UNION
SELECT '2020 - by customerID', COUNT(DISTINCT(o.customerid))
FROM tblCustomers c
INNER JOIN tblOrders o ON c.customerid = o.customerID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND DATEPART(YY, o.orderDate) = '2020'