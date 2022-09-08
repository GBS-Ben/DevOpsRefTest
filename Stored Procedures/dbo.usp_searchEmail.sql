CREATE PROC [dbo].[usp_searchEmail] @email NVARCHAR(255)
AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		07/26/18
-- Purpose		used to search emails for intranet
--					    called by [usp_MIG_HOMLIVE] near Z97.

-------------------------------------------------------------------------------
-- Modification History
--
-- 7/26/18		created, jf.
-------------------------------------------------------------------------------

SELECT DISTINCT orderID, orderNo
FROM tblOrders o
INNER JOIN tblCustomers c
	ON o.customerID = c.customerID
WHERE c.email = @email
UNION
SELECT orderID, orderNo
FROM tblOPPO_email
WHERE email = @email