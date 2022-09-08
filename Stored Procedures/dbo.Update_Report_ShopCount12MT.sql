CREATE PROCEDURE [dbo].[Update_Report_ShopCount12MT]
AS
-------------------------------------------------------------------------------
-- Author Jeremy Fifer
-- Created 09/16/21
-- Purpose Calcs shop count data for header display.
-------------------------------------------------------------------------------
-- Modification History



--09/16/21 Created, jf.
--01/12/22 Updated @StarDate



-------------------------------------------------------------------------------
DECLARE @StartDate DATETIME
,@EndDate DATETIME



--SET @StartDate = GETDATE()-365 --ORIGINAL
SET @StartDate = CONVERT(DATETIME, (CONVERT(VARCHAR(50), DATEPART(MM,GETDATE()-365)) + '/' + CONVERT(VARCHAR(50), DATEPART(DD,GETDATE()-365)) + '/' + CONVERT(VARCHAR(50), DATEPART(YYYY,GETDATE()-365))))
SET @EndDate = GETDATE()



TRUNCATE TABLE Report_ShopCount12MT
INSERT INTO Report_ShopCount12MT (shopCount, lastModified)
SELECT COUNT(DISTINCT(op.GBSCompanyID)), GETDATE()
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND o.orderDate BETWEEN @StartDate AND @EndDate
AND LEFT(o.orderNo, 3) IN ('HOM', 'NCC', 'MRK')
AND op.deleteX <> 'yes'