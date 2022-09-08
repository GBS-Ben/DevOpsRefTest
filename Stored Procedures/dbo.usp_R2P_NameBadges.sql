--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//
CREATE proc usp_R2P_NameBadges
as
/*
This procedure is called by usp_executeJob_R2P_NameBadges and resides inside the job "R2P - Name Badges".
This procedure grabs all valid R2P name badge line items and preps them for export to XLS.
This procedure also preps the table tblR2P_NameBadges, for use in displaying badges that are R2P on the intranet.
*/


delete from tblR2P_NameBadges

set identity_insert tblR2P_NameBadges ON
insert into tblR2P_NameBadges (sortNo, Contact, Title, BKGND, SHT, POS, 
COLogo, COtextAll, COtext1, COtext2, RO, orderNo, 
pkid, OPPO_ordersProductsID, QTY, orderID, productCode)
select 
sortNo, Contact, Title, BKGND, SHT, POS, 
COLogo, COtextAll, COtext1, COtext2, RO, orderNo, 
pkid, OPPO_ordersProductsID, QTY, orderID, productCode
--into tblR2P_NameBadges
from tblBadges
where OPPO_ordersProductsID in
(select distinct [ID] from tblOrders_Products where NBPRINT is NULL)
set identity_insert tblR2P_NameBadges OFF

update tblOrders_Products
set NBPRINT=getdate()
where [ID] in
(select distinct OPPO_ordersProductsID from tblR2P_NameBadges where OPPO_ordersProductsID is NOT NULL)

--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//--//