CREATE proc usp_R2P_displayAll
as
/*
This procedure grabs all valid R2P line items for display on the Intranet prior to exec of usp_executeJob_R2P_NameBadges.
Used prior to exec usp_executeJob_R2P_NameBadges, which will set all NBPRINT values to getDate() and thus negate this proc.
*/
select sortNo, Contact, Title, BKGND, SHT, POS, 
COLogo, COtextAll, COtext1, COtext2, RO, orderNo, 
pkid, OPPO_ordersProductsID, QTY, orderID, productCode
from tblR2P_NameBadges