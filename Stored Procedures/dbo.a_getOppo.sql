CREATE PROCEDURE "dbo"."a_getOppo"
@opid INT 
AS
select * from tblordersproducts_productOptions
where ordersProductsId = @opid