CREATE proc [dbo].[GBSReports_OrdersKWMcid] as

--The second tab shows orders that have a RE/MAX MCID associated with it.

SELECT DISTINCT op.GBSCOMPANYID, cl.CompanyName,  o.orderNo, o.orderDate, o.calcOrderTotal, o.orderStatus--, op.ID, op.productCode, op.productName, op.fasttrak_status, op.processType, op.deleteX
,c.firstname, c.surname, c.email, c.phone, 
s.shipping_company, s.shipping_fullname, s.shipping_street, s.shipping_street2, s.shipping_suburb, s.shipping_state, s.shipping_postcode
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblCustomers c ON o.customerID = c.customerID
INNER JOIN tblCustomers_ShippingAddress s ON o.orderno = s.orderno
LEFT JOIN dbo.CompanyList cl ON cl.GbsCompanyId=op.GbsCompanyId
WHERE o.orderStatus NOT IN ('failed', 'cancelled')
AND op.deleteX <> 'yes'
AND op.GBSCOMPANYID LIKE 'KW%'
and o.orderDate>='1/1/2020'
ORDER BY o.orderDate DESC