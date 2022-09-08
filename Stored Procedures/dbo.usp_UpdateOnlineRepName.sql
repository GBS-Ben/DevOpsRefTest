CREATE PROCEDURE [dbo].[usp_UpdateOnlineRepName]
AS
SET NOCOUNT  ON;


--This is a band-aid for some oddness that I can't figure out with records on NOP 

UPDATE s 
SET repName = c.email
FROM tblorders s
INNER JOIN dbo.nopcommerce_tblNopOrder o ON o.GBSOrderId = s.OrderNo
INNER JOIN dbo.nopcommerce_customer c ON c.id = o.impersonator
WHERE repName = 'Online'
	AND impersonator IS NOT NULL