CREATE PROC [dbo].[usp_MIG_EMAIL]
AS

DELETE FROM customerEmailPROP

INSERT INTO customerEmailPROP (customerID, email)
SELECT customerID, email
FROM dbo.HOMLIVE_tblCustomers 

UPDATE tblCustomers
SET email = a.email
FROM customerEmailPROP a 
JOIN tblCustomers b
	ON a.customerID = b.customerID-444333222
WHERE a.email <> b.email