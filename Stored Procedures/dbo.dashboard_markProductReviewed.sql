CREATE PROCEDURE "dbo"."dashboard_markProductReviewed"
@opid INT
AS

UPDATE tblOrders_Products
SET isValidated = 1
WHERE id = @opid;

INSERT INTO dashboard_reviewedProducts
	(ordersProductsID, reviewedOn)
VALUES
	(@opid, GETDATE())