--//
create proc usp_getBadges 
as

delete from tblBadgesR2P

set identity_insert tblBadgesR2P ON
insert into tblBadgesR2P (sortNo, Contact, Title, BKGND, SHT, POS, 
COLogo, COtextAll, COtext1, COtext2, RO, orderNo, 
pkid, OPPO_ordersProductsID, QTY, orderID, productCode)
select 
sortNo, Contact, Title, BKGND, SHT, POS, 
COLogo, COtextAll, COtext1, COtext2, RO, orderNo, 
pkid, OPPO_ordersProductsID, QTY, orderID, productCode
from tblBadges
where OPPO_ordersProductsID in
(select distinct [ID] from tblOrders_Products where NBPRINT is NULL)
set identity_insert tblBadgesR2P OFF

select * from tblBadgesR2P
--//