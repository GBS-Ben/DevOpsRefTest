CREATE PROC [dbo].[ReportMarkfulShopsForCSRs]
AS
/*
-------------------------------------------------------------------------------
Author      JF
Created     09APR2021
Purpose     Gives CSRs a call list
-------------------------------------------------------------------------------
Modification History

04/09/2021		JF, created
*/

TRUNCATE TABLE ReportMarkfulShops
;WITH CTE AS
(SELECT companyId, parentCompanyId, companyLongCode, companyOfficeCode, companyShortCode, companyName, companyMainLogoSm, isParentCompany, isTopCompany, isActive, freeBC, NopCategoryId, GbsCompanyId, CreateDate, ModifiedDate
FROM dbo.HOMLIVE_CompanyList)

INSERT INTO ReportMarkfulShops (orderID, orderNo, orderDate, companyName, GBSCompanyID)
SELECT DISTINCT o.orderID,
o.orderNo,
o.orderDate,
CTE.companyName,
CTE.GBSCompanyID
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN CTE ON CTE.GBSCompanyID = op.GBSCompanyID
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND op.deleteX <> 'yes'
AND o.orderDate > GETDATE() - 365

TRUNCATE TABLE ReportMarkfulShopsCount
INSERT INTO ReportMarkfulShopsCount (GBSCompanyID, numOrders)
SELECT GBSCompanyID, COUNT(GBSCompanyID) AS numOrders
FROM ReportMarkfulShops
GROUP BY GBSCompanyID

UPDATE r
SET ShopSetUpOrder = o.orderNo
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON op.id = oppx.ordersproductsid
INNER JOIN ReportMarkfulShops r ON r.companyName = oppx.textValue
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND op.productCode = 'MC00SU-001'
AND op.deleteX <> 'yes'
AND oppx.deleteX <> 'yes'
AND o.orderNo NOT IN ('HOM951630', 'HOM1069410')

SELECT DISTINCT r.companyName, r.GBSCompanyID, r.ShopSetUpOrder, c.numOrders, s.LatestDate
FROM ReportMarkfulShops r
INNER JOIN 
	(SELECT MAX(orderDate) as LatestDate, GBSCompanyID
	FROM ReportMarkfulShops
	GROUP BY GBSCompanyID) s 
ON r.GBSCompanyID = s.GBSCompanyID
INNER JOIN ReportMarkfulShopsCount c ON c.GBSCompanyID = r.GBSCompanyID
WHERE s.GBSCompanyID = r.GBSCompanyID
ORDER BY c.numOrders DESC