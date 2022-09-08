CREATE PROCEDURE [dbo].[usp_SteveSpecialProds]
   @prodMain AS VARCHAR(50),
   @prodYear AS VARCHAR(50)

AS 
  SELECT DISTINCT email
FROM tblCustomers c
JOIN tblOrders o ON c.customerID = o.customerID
WHERE o.orderStatus <> 'cancelled' AND o.orderStatus <> 'failed'

-- (Note A)
AND c.email IN
	(SELECT DISTINCT email 
	FROM tblCustomers
	WHERE customerID IN
		(SELECT DISTINCT customerID
		FROM tblOrders
		WHERE orderStatus <> 'cancelled' 
		AND orderStatus <> 'failed'
		AND orderID IN
			(SELECT DISTINCT orderID 
			FROM tblOrders_Products 
			WHERE deleteX <> 'yes'
			AND productCode LIKE @prodMain + '%'
			)
		)
	)

-- (Note B)
AND c.email NOT IN
	(SELECT DISTINCT email 
	FROM tblCustomers
	WHERE customerID IN
		(SELECT DISTINCT customerID
		FROM tblOrders
		WHERE orderStatus <> 'cancelled' 
		AND orderStatus <> 'failed'
		AND orderID IN
			(SELECT DISTINCT orderID 
			FROM tblOrders_Products 
			WHERE deleteX <> 'yes'
			AND productCode LIKE @prodYear + '%'
			)
		)
	)

-- (Note C)
AND email LIKE '%@%'
AND email NOT LIKE '@%'
AND email NOT LIKE '%,%'
AND email NOT LIKE '%"%'
AND email NOT LIKE '%-list@%'
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
AND email NOT LIKE '%Leike%'

Order by email