CREATE VIEW v_badges
AS
SELECT a.sortNo, a.Contact, a.Title, a.BKGND, a.sht, a.pos, a.COLogo, a.COtextAll, a.COtext1, a.COtext2, a.RO, a.orderNo, 
a.OPPO_ordersProductsID,
b.shipName, b.shipCompany, b.[address], b.address2, b.city, b.st, b.zip, b.badgeName, b.badgeQTY, b.PKID
FROM
tblBadges a JOIN tblBadges_Addresses b
ON a.orderNo = b.orderNo