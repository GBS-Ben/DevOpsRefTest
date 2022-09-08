CREATE proc usp_R2P_displayRecent @dd int
as
/*
This procedure grabs all RECENT R2P line items for display on the Intranet AFTER exec of usp_executeJob_R2P_NameBadges.
Used AFTER exec usp_executeJob_R2P_NameBadges, which set all NBPRINT values to getDate() and thus populated this proc.
*/
select 
sortNo, Contact, Title, BKGND, SHT, POS, 
COLogo, COtextAll, COtext1, COtext2, RO, orderNo, 
pkid, OPPO_ordersProductsID, QTY, orderID, productCode
from tblBadges
where OPPO_ordersProductsID in
(select distinct [ID] from tblOrders_Products 
where NBPRINT is not NULL
and datediff(dd,NBPRINT,getdate())<=@dd)