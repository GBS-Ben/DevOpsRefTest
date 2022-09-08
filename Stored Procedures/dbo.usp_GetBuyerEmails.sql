


CREATE PROC usp_GetBuyerEmails
@season VARCHAR(255), @year VARCHAR(4)
AS

/*
Example:
"I need all football buyer emails for 2013."
EXEC usp_GetBuyerEmails 'football', '2013'
*/

SELECT DISTINCT email 
FROM tblCustomers 
WHERE customerID IN
	(SELECT customerID 
	FROM tblOrders 
	WHERE orderStatus <> 'Cancelled' 
	AND orderStatus <> 'Failed'
	AND orderStatus <> 'Waiting For Payment'
	AND orderID IN
		(SELECT orderID 
		FROM tblOrders_Products 
		WHERE deleteX <> 'yes'
		AND productName LIKE '%' + @season + '%' 
		AND productName LIKE '%' + @year + '%' 
		)
	)
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
AND email IS NOT NULL
AND email NOT LIKE '%Leike%'
AND company NOT LIKE '%Leike%'
ORDER BY email