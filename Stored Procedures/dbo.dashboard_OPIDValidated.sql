CREATE PROCEDURE "dbo"."dashboard_OPIDValidated"
@opid VARCHAR(20) 
AS
UPDATE tblOrders_products
SET isValidated = 1
where ID = @opid;