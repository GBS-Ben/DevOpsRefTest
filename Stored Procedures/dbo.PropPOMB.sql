CREATE PROC [dbo].[PropPOMB]
AS
/*
-------------------------------------------------------------------------------------
 Author     Jeremy Fifer
Created     09/11/19
Purpose     updates PO/MB up top.
-------------------------------------------------------------------------------------
Modification History

09/11/19		JF, new

-------------------------------------------------------------------------------------
*/

DELETE FROM [dbo].[HOMLive_tblCustomers_propagateChangesUp]
WHERE isUpdated = 1

INSERT INTO [dbo].[HOMLive_tblCustomers_propagateChangesUp] (customerID, po, monthlyBill, refreshDate, isUpdated)
SELECT customerID - 444333222, po, monthlyBill, GETDATE(), 0
FROM tblCustomers 
WHERE DATEDIFF(mi, modified_on, GETDATE()) <= 30