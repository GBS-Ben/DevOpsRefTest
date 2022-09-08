CREATE PROCEDURE [dbo].[usp_getAllHOMCustomers]
AS
---------------------------------------------------------------------
-- CHANGE LOG
-- 2020014	BJS Removed much of the logic to get what Mike really needs
--
--04/27/21		CKB, Markful
----------------------------------------------------------------------

;WITH cteEMAILs
AS
(
SELECT  DISTINCT c.email, c.company, SUBSTRING(c.postcode,1,5) AS 'Zip Code'
FROM tblCustomers AS c 
INNER JOIN tblOrders AS o 
	ON c.customerid = o.customerID 
WHERE orderStatus NOT IN ('cancelled','failed') 
	AND LEFT(o.orderNo,3)  IN ('HOM','MRK')
 	AND o.orderDate >= DATEADD(mm, -25, GETDATE())
	AND email LIKE '%@%'
	AND email NOT LIKE '@%'
	AND email NOT LIKE '%-list@%'
	AND email NOT LIKE '%,%'
	AND email NOT LIKE '%"%'
	AND email NOT LIKE '%"@%'
	AND email NOT LIKE '%-request@%'
	AND email NOT LIKE 'administrator@%'
	AND email NOT LIKE 'admissions@%'
	AND email NOT LIKE 'alumni@%'
	AND email NOT LIKE '%announce%'
	AND email NOT LIKE 'anonymous@%'
	AND email NOT LIKE 'billing@%'
	AND email NOT LIKE 'busdev@%'
	AND email NOT LIKE 'careers@%'
	AND email NOT LIKE 'comments@%'
	AND email NOT LIKE 'contact@%'
	AND email NOT LIKE 'customerservice@%'
	AND email NOT LIKE 'development@%'
	AND email NOT LIKE 'editor@%'
	AND email NOT LIKE 'enquiries@%'
	AND email NOT LIKE 'feedback@%'
	AND email NOT LIKE 'help@%'
	AND email NOT LIKE 'hr@%'
	AND email NOT LIKE 'info@%'
	AND email NOT LIKE 'info-%@%'
	AND email NOT LIKE 'inquiries@%'
	AND email NOT LIKE 'jobs@%'
	AND email NOT LIKE 'join@%'
	AND email NOT LIKE 'join-%@%'
	AND email NOT LIKE 'list@%'
	AND email NOT LIKE 'list-%@%'
	AND email NOT LIKE 'mail@%'
	AND email NOT LIKE 'marketing@%'
	AND email NOT LIKE 'newsletter@%'
	AND email NOT LIKE 'postmaster@%'
	AND email NOT LIKE 'pr@%'
	AND email NOT LIKE 'publications@%'
	AND email NOT LIKE 'register@%'
	AND email NOT LIKE 'request@%'
	AND email NOT LIKE 'root@%'
	AND email NOT LIKE 'security@%'
	AND email NOT LIKE 'service@%'
	AND email NOT LIKE 'services@%'
	AND email NOT LIKE 'staff@%'
	AND email NOT LIKE '%subscribe%'
	AND email NOT LIKE 'support@%'
	AND email NOT LIKE 'tech@%'
	AND email NOT LIKE 'techsupport@%'
	AND email NOT LIKE 'test@%'
	AND email NOT LIKE 'user@%'
	AND email NOT LIKE 'webadmin@%'
	AND email NOT LIKE 'webdesign@%'
	AND email NOT LIKE 'webinfo@%'
	AND email NOT LIKE 'webmaster@%'
	AND email NOT LIKE 'welcome@%'
	AND email NOT LIKE '%www%'
	AND email NOT LIKE '%hk' 
	AND email NOT LIKE '%hostmaster%' 
	AND email NOT LIKE '%domain%'
	AND email NOT LIKE '%au'
	AND email NOT LIKE '%lo'
	AND email NOT LIKE '%premiumservices%'
	AND email NOT LIKE '%safe%'
	AND email NOT LIKE '%majordomo%'
	AND email NOT LIKE '%au'
	AND email NOT LIKE '%lo'
	AND email NOT LIKE '%spam%'
	AND email IS NOT NULL
	AND email NOT LIKE '%Leike%'
	AND ISNULL(company, '') NOT LIKE '%Leike%'
	AND email NOT LIKE '1@'
	AND email NOT LIKE '% %'
	AND email NOT LIKE '%fairwaymc.com%'
	)  
--	UNION

--	SELECT DISTINCT 
--	x.email, c.company, SUBSTRING(c.postcode,1,5) AS 'Zip Code'
--	FROM tblOPPO_Email x
--	INNER JOIN tblOrders o
--		ON x.orderID = o.orderID
--	INNER JOIN tblCustomers c
--		ON o.customerID = c.customerID
--	WHERE orderStatus NOT IN ('cancelled','failed') 
--	AND o.membershipType IN ('HOM Customer', 'HOM')
--	AND o.orderDate >= DATEADD(mm, -13, GETDATE())
--	AND x.email LIKE '%@%'
--	AND x.email NOT LIKE '@%'
--	AND x.email NOT LIKE '%-list@%'
--	AND x.email NOT LIKE '%,%'
--	AND x.email NOT LIKE '%"%'
--	AND x.email NOT LIKE '%"@%'
--	AND x.email NOT LIKE '%-request@%'
--	AND x.email NOT LIKE 'administrator@%'
--	AND x.email NOT LIKE 'admissions@%'
--	AND x.email NOT LIKE 'alumni@%'
--	AND x.email NOT LIKE '%announce%'
--	AND x.email NOT LIKE 'anonymous@%'
--	AND x.email NOT LIKE 'billing@%'
--	AND x.email NOT LIKE 'busdev@%'
--	AND x.email NOT LIKE 'careers@%'
--	AND x.email NOT LIKE 'comments@%'
--	AND x.email NOT LIKE 'contact@%'
--	AND x.email NOT LIKE 'customerservice@%'
--	AND x.email NOT LIKE 'development@%'
--	AND x.email NOT LIKE 'editor@%'
--	AND x.email NOT LIKE 'enquiries@%'
--	AND x.email NOT LIKE 'feedback@%'
--	AND x.email NOT LIKE 'help@%'
--	AND x.email NOT LIKE 'hr@%'
--	AND x.email NOT LIKE 'info@%'
--	AND x.email NOT LIKE 'info-%@%'
--	AND x.email NOT LIKE 'inquiries@%'
--	AND x.email NOT LIKE 'jobs@%'
--	AND x.email NOT LIKE 'join@%'
--	AND x.email NOT LIKE 'join-%@%'
--	AND x.email NOT LIKE 'list@%'
--	AND x.email NOT LIKE 'list-%@%'
--	AND x.email NOT LIKE 'mail@%'
--	AND x.email NOT LIKE 'marketing@%'
--	AND x.email NOT LIKE 'newsletter@%'
--	AND x.email NOT LIKE 'postmaster@%'
--	AND x.email NOT LIKE 'pr@%'
--	AND x.email NOT LIKE 'publications@%'
--	AND x.email NOT LIKE 'register@%'
--	AND x.email NOT LIKE 'request@%'
--	AND x.email NOT LIKE 'root@%'
--	AND x.email NOT LIKE 'security@%'
--	AND x.email NOT LIKE 'service@%'
--	AND x.email NOT LIKE 'services@%'
--	AND x.email NOT LIKE 'staff@%'
--	AND x.email NOT LIKE '%subscribe%'
--	AND x.email NOT LIKE 'support@%'
--	AND x.email NOT LIKE 'tech@%'
--	AND x.email NOT LIKE 'techsupport@%'
--	AND x.email NOT LIKE 'test@%'
--	AND x.email NOT LIKE 'user@%'
--	AND x.email NOT LIKE 'webadmin@%'
--	AND x.email NOT LIKE 'webdesign@%'
--	AND x.email NOT LIKE 'webinfo@%'
--	AND x.email NOT LIKE 'webmaster@%'
--	AND x.email NOT LIKE 'welcome@%'
--	AND x.email NOT LIKE '%www%'
--	AND x.email NOT LIKE '%hk' 
--	AND x.email NOT LIKE '%hostmaster%' 
--	AND x.email NOT LIKE '%domain%'
--	AND x.email NOT LIKE '%au'
--	AND x.email NOT LIKE '%lo'
--	AND x.email NOT LIKE '%premiumservices%'
--	AND x.email NOT LIKE '%safe%'
--	AND x.email NOT LIKE '%majordomo%'
--	AND x.email NOT LIKE '%au'
--	AND x.email NOT LIKE '%lo'
--	AND x.email NOT LIKE '%spam%'
--	AND x.email IS NOT NULL
--	AND x.email NOT LIKE '%Leike%'
--	AND company NOT LIKE '%Leike%'
--	AND x.email NOT LIKE '1@'
--	AND x.email NOT LIKE '% %'
--	AND x.email NOT LIKE '%fairwaymc.com%'
--)

SELECT email , company, [Zip Code]
FROM cteEMAILs
WHERE email LIKE '%_@__%.__%' 
    AND PATINDEX('%[^a-z,0-9,@,.,_]%', REPLACE(email, '-', 'a')) = 0