CREATE PROC [dbo].[usp_mergeCustomers_backup]
AS
/*
THESE ARE JUST NOTES. THIS IS NOT AN OPERATING SPROC, BUT MAY LEAD TO ONE DOWN THE ROAD.
``````````````````````````````````````````````````````````````````````````````````````````

Is it possible to have these two accounts on dashboard and in the intranet (order history) 
all roll up under the dustin@griffithsellscolorado.com address?

dustin@griffithsellscolorado.com (http://intranet/gbs/admin/orders.asp?s=dustin@griffithsellscolorado.com&sparam=a.email)
jessica@griffithhometeam.com (http://intranet/gbs/admin/orders.asp?s=jessica@griffithhometeam.com&sparam=a.email)

`````````````````````````````````````````````````````````````````````````````````````````
OR
``````````````````````````````````````````````````````````````````````````````````````````
Here's another question like it:

Can you please merge customer # 444355733 (http://192.168.1.7/gbs/admin/customerView.asp?m=edit&i=444355733&p=orderView.asp) 
under 444475053 (http://192.168.1.7/gbs/admin/customerView.asp?m=edit&i=444475053&p=orderView.asp) …

So that she can use her new email address Dorothybeckley@icloud.com?
`````````````````````````````````````````````````````````````````````````````````````````
*/

-- Did you get a question like above?
-- Here's what you do.

-- first grab the customerIDs for both email addresses, on both local (444) and remote (non444) like this:
SELECT * FROM tblCustomers
WHERE email = 'dustin@griffithsellscolorado.com' -- 444334476 / 1254

SELECT * FROM tblCustomers
WHERE email = 'jessica@griffithhometeam.com' --444425556 / 92334

SELECT * FROM SQL01.HOMLIVE.dbo.tblCustomers
WHERE email = 'dustin@griffithsellscolorado.com' -- 444334476 / 1254

SELECT * FROM SQL01.HOMLIVE.dbo.tblCustomers
WHERE email = 'jessica@griffithhometeam.com' --444425556 / 92334

-- next update three locations as shown below. That's it. No need to update tblCustomers. Make sure to run on a single order first, and check intranet.
-- no need to change the static SQL01 data, as it is never used post-migration.
UPDATE tblOrders
SET customerID = 444334476
WHERE customerID = 444425556
AND orderNo = 'HOM377907'

UPDATE SQL01.HOMLIVE.[dbo].[tblDashboard_Orders]
SET customerID = 444334476
WHERE customerID = 444425556 
AND orderNo = 'HOM377907'

UPDATE tblCustomers_ShippingAddress
SET customerID = 444334476
WHERE customerID = 444425556 
AND orderNo = 'HOM377907'


-- Here it is again for a different set of data:
SELECT * FROM tblCustomers WHERE customerID = 444355733 --FROM (22511)
SELECT * FROM tblCustomers WHERE customerID = 444475053 --TO (141831)

SELECT * FROM SQL01.HOMLIVE.dbo.tblCustomers WHERE customerID = 22511 --FROM
SELECT * FROM SQL01.HOMLIVE.dbo.tblCustomers WHERE customerID = 141831 --TO

UPDATE tblOrders
SET customerID = 444475053
WHERE customerID = 444355733

UPDATE SQL01.HOMLIVE.[dbo].[tblDashboard_Orders]
SET customerID = 141831
WHERE customerID = 22511 

UPDATE tblCustomers_ShippingAddress
SET customerID = 444475053
WHERE customerID = 444355733