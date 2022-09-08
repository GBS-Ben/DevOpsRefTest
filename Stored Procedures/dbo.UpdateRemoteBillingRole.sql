CREATE PROCEDURE [dbo].[UpdateRemoteBillingRole]
AS
SET NOCOUNT ON;
BEGIN

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--There is an issue with migrating customers down from NOP. 
--The offset causes duplicates to be created
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		UPDATE t
		SET monthlyBill  = 1
		FROM tblcustomers t
		where email IN (
		SELECT email FROM tblCustomers where monthlybill = 1 AND email <> '' AND email IS NOT NULL) AND monthlyBill = 0

		UPDATE t
		SET po  = 1
		FROM tblcustomers t
		where email IN (
		SELECT email FROM tblCustomers where po = 1 AND email <> '' AND email IS NOT NULL) AND po = 0

			DECLARE @Customer TABLE (rownum int identity(1,1), email varchar(455), po int, monthlybill int)
			INSERT @Customer (email, po, monthlybill)
			SELECT DISTINCT email, po, monthlyBill
			FROM tblCustomers tc
			WHERE email IS NOT NULL and Email <> ''
				AND (po = 1 OR monthlyBill = 1)

		

		;WITH cte
		AS
		(
			SELECT c.id AS CustomerId, 9 AS CustomerRole
			FROM dbo.nopcommerce_customer c 
			INNER JOIN @Customer tc ON isnull( c.username,'') = isnull(tc.email,'-')
			LEFT JOIN  dbo.nopcommerce_customer_CustomerRole_mapping cm on cm.customer_id = c.id and cm.customerrole_id = 9
			WHERE MonthlyBill = 1
				AND cm.customer_id is null
			)
		INSERT dbo.nopcommerce_customer_CustomerRole_mapping (customer_id, customerrole_id)
		SELECT DISTINCT CustomerId, CustomerRole
		FROM cte

		;WITH cte2
		AS
		(
			SELECT  c.id AS CustomerId, 9 AS CustomerRole
			FROM dbo.nopcommerce_customer c 
			INNER JOIN @Customer tc  ON isnull( c.email,'') = isnull(tc.email,'-')
			LEFT JOIN dbo.nopcommerce_customer_CustomerRole_mapping cm on cm.customer_id = c.id and cm.customerrole_id = 9
			WHERE MonthlyBill = 1
				and cm.customer_id is null
		)
		INSERT dbo.nopcommerce_customer_CustomerRole_mapping (customer_id, customerrole_id)
		SELECT DISTINCT CustomerId, CustomerRole
		FROM cte2


		;WITH cte3
		AS 
		(
			SELECT  c.id AS CustomerId, 8 AS CustomerRole
			FROM  dbo.nopcommerce_customer c 
			INNER JOIN @Customer tc  ON isnull( c.username,'') = isnull(tc.email,'-')
			LEFT JOIN  dbo.nopcommerce_customer_CustomerRole_mapping cm on cm.customer_id = c.id and cm.customerrole_id = 8
			WHERE PO = 1
				AND cm.customer_id is null
			)
		INSERT dbo.nopcommerce_customer_CustomerRole_mapping (customer_id, customerrole_id)
		SELECT DISTINCT CustomerId, CustomerRole
		FROM cte3

		; WITH cte4
		AS 
		(
			SELECT  c.id AS CustomerId, 8 AS CustomerRole
			FROM dbo.nopcommerce_customer c 
			INNER JOIN @Customer tc  ON isnull( c.email,'') = isnull(tc.email,'-')
			LEFT JOIN dbo.nopcommerce_customer_CustomerRole_mapping cm on cm.customer_id = c.id and cm.customerrole_id = 8
			WHERE PO = 1
				AND cm.customer_id is null
			)
		INSERT dbo.nopcommerce_customer_CustomerRole_mapping (customer_id, customerrole_id)
		SELECT DISTINCT CustomerId, CustomerRole
		FROM cte4








END