
CREATE PROCEDURE ReportMC
@2DigitCode CHAR(2),
@startDate DATETIME = '19740101',
@endDate DATETIME = '20590101'
AS
/*
-------------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     06/25/19
Purpose     Retrieves sales metrics per MC Code
-------------------------------------------------------------------------------------
Modification History:

06/25/19		created, jf.


Usage:
EXEC ReportMC 'EX' --ALLTIME
EXEC ReportMC 'EX', '19740101', '20210101' --ALLTIME
-------------------------------------------------------------------------------------
*/

IF OBJECT_ID('tempdb..#OrderXML') IS NOT NULL
DROP TABLE #rptBaseProducts

CREATE TABLE #rptBaseProducts(
	OPID INT NOT NULL,
	productCode VARCHAR (100),
	productName VARCHAR (255),
	productQuantity INT,
	productPrice MONEY,
	totalSold MONEY
	)

INSERT INTO #rptBaseProducts (OPID, productCode, productName, productQuantity, productPrice, totalSold)
SELECT DISTINCT id, productCode, productName, productQuantity, productPrice, 
productQuantity * productPrice AS totalSold
FROM tblOrders_Products
WHERE SUBSTRING(productCode, 3, 2) = @2DigitCode

;WITH cte
AS
(SELECT DISTINCT 
OPID,
SUBSTRING(productCode, 1, 2) AS productType
FROM #rptBaseProducts)

SELECT cte.productType, COUNT(DISTINCT(bp.OPID)), SUM(bp.totalSold)
FROM cte 
INNER JOIN #rptBaseProducts bp ON cte.OPID = bp.OPID
GROUP BY cte.productType
WITH ROLLUP