CREATE proc usp_R2P_Reprint
@ID int
AS
/*
This procedure is used on the orderEdit.asp page, accepts the tblOrders_Products.[ID] field for a given line item that needs to be reprinted on the R2P.
*/
update tblOrders_Products
set NBPRINT=NULL 
where NBPRINT is NOT NULL 
and [ID]=@ID