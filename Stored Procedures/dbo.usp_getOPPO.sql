create proc usp_getOPPO 
@orderNo varchar(50)
as
select * from tblOrdersProducts_productOptions
where ordersProductsID in
(select [ID] from tblOrders_Products where orderID in
(select orderID from tblOrders where orderNo = @orderNo))