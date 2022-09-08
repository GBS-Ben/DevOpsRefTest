CREATE PROC usp_QTYResubmit
@ID INT,
@QTY INT

AS
INSERT INTO tblFT_QTYResubmit (ordersProductsID, QTY, submitDate)
SELECT @ID, @QTY, GETDATE()