
------------------------------------------------------------------------------------------------------------------------
CREATE PROC ReportSalesByProductCode
AS

IF OBJECT_ID('tempdb..#RPTCALC') IS NOT NULL DROP TABLE #RPTCALC
CREATE TABLE #RPTCALC
	(RowID INT IDENTITY(1, 1), 
	XX NVARCHAR(50),
	PC CHAR(2), 
	MM CHAR(2),
	YYYY CHAR(4),
	TotalSales MONEY)
DECLARE @NumberRecords INT, @RowCount INT
DECLARE @SUM_OPID MONEY,
		@SUM_OPPX MONEY,
		@PC CHAR(2),
		@MM CHAR(2),
		@YYYY CHAR(4)

--kill tables
TRUNCATE TABLE ReportMMYYYY_WithSales
TRUNCATE TABLE #RPTCALC

--work tables
INSERT INTO #RPTCALC (XX, PC, MM, YYYY)
SELECT DISTINCT CONVERT(CHAR(2), a.productCode) + '_' + b.YYYY + '_' + b.MM AS XX,
CONVERT(CHAR(2), a.productCode) AS PC, b.MM, b.YYYY
FROM [ReportProductCodes] a
INNER JOIN ReportMMYYYY b ON 1=1
--WHERE b.YYYY = 2019
--AND CONVERT(CHAR(2), a.productCode)  = 'SN'
ORDER BY 1

--get the number of records in the temp table
SET @NumberRecords = @@ROWCOUNT
SET @RowCount = 1

--get loopy
WHILE @RowCount < = @NumberRecords
BEGIN
	
SELECT @PC = PC,
@MM = MM,
@YYYY = YYYY
FROM #RPTCALC
WHERE RowID = @RowCount

SET @SUM_OPID = 0
SET @SUM_OPID = (SELECT 
				SUM(op.productQuantity * op.productPrice)
				FROM tblOrders o
				INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
				WHERE SUBSTRING(op.productCode, 1, 2) = @PC
				AND op.deleteX <> 'yes'
				AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
				AND DATEPART(MM, o.orderDate) = @MM
				AND DATEPART(YY, o.orderDate) = @YYYY)

SET @SUM_OPPX = 0
SET @SUM_OPPX = (SELECT 
				SUM(oppx.optionPrice)
				FROM tblOrders o
				INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
				INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
				WHERE SUBSTRING(op.productCode, 1, 2) = @PC
				AND op.deleteX <> 'yes'
				AND oppx.deleteX <> 'yes'
				AND o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
				AND DATEPART(MM, o.orderDate) = @MM
				AND DATEPART(YY, o.orderDate) = @YYYY)

INSERT INTO ReportMMYYYY_WithSales (PC, MM, YYYY, TotalOPIDSales, TotalOPPXSales, TotalSales)
SELECT @PC, @MM, @YYYY, @SUM_OPID, @SUM_OPPX, ISNULL(@SUM_OPID, 0) + ISNULL(@SUM_OPPX, 0)

SET @RowCount = @RowCount + 1
END

SELECT PC, MM, YYYY, TotalOPIDSales, TotalOPPXSales, TotalSales 
FROM ReportMMYYYY_WithSales
ORDER BY PC, YYYY, MM

------------------------------------------------------------------------------------------------------------------------