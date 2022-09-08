CREATE PROC [dbo].[popArtGate]

AS

/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     11/20/19
Purpose     Populates ArtGate with OPIDs that are shown to the artgate so that they can 
			qualify for fasTrak via a manual GTG operation. This is important because
			the FT flows check to see OPIDs that have an OPPO with a "%_J" text value, 
			which denotes that it is a Furnished Art OPID, are properly gated from production
			even though they are processType='fasTrak'.

	--MORE NOTES:
	The op.processType = 'fasTrak' is normally a good enough check for FA's that have gone through ARTGATE because normal FA OPIDs are processType='Custom' are changed to op.processType = 'fasTrak' upon receiving the G2G designation.
	
	However, some OPIDs in ARTGATE because they have an OPPO with RIGHT(oppz.textValue, 2) = '_J'. These OPIDs are typically already op.processType = 'fasTrak', and therefore make it into the FT flows by that virtue alone. This is bad. So, during the op.fastTrak_status = 'Good to Go' qualification in the initial query, there is some ArtGate logic in there to find this exception to the rule and prevent OPIDs with this secondary condition from entering the FT flow without an ArtGate check. The way this is done is through the stored proc [popArtGate] which inserts every OPID that qualifies for ArtGate into a table, which is used here to qualify for the flow.

-------------------------------------------------------------------------------
Modification History

11/20/19	JF, Created.
04/27/21	CKB, Markful

-------------------------------------------------------------------------------
*/
;WITH CTE AS (
SELECT DISTINCT
op.ID AS OPID
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
WHERE 
o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment', 'On HOM Dock', 'On MRK Dock')
AND op.deleteX <> 'yes'
AND oppx.deleteX <> 'yes'
AND op.fastTrak_status = 'In House'
AND op.productCode IN ('BMFAH1-001-100', 'BPFAH1-001-100', 'BPFAH1-201-100', 'BPFAV1-201-100', 'CMFAH1-001-100', 'CMFAH1-201-100', 'EVFAW1-001-100', 'EVFAW1-201-100', 'FABUH1-001-100', 'FABUV1-001-100', 'FACCH1-001-100', 'FACHH1-001-100', 'FAEXH1-001-100', 'FAEXV1-001-100', 'FAFCH1-001-100', 'FAFCV1-001-100', 'FAJUH1-001-100', 'FAJUV1-001-100', 'FANCV1-001-100', 'FANSH1-001-100', 'FAQCH1-001-100', 'FAQCV1-001-100', 'FAQMH1-001-100', 'FAQSH1-001-100', 'LHFAW1-001-100', 'LHFAW1-201-100', 'NBFAOB-001-100', 'NBFAOB-201-100', 'NBFARB-001-100', 'NBFARB-201-100', 'NCFAH6-00001', 'NCFAH6-00001CU', 'NCFAH6-00001CUGC', 'NCFAH6-00001GC', 'NCFAH6-100201', 'NCFAV6-00001', 'NCFAV6-00001CU', 'NCFAV6-00001CUGC', 'NCFAV6-00001GC', 'NCFAV6-100201', 'PLFAH1-001-100', 'PLFAH1-201-100', 'SNFAD1-201-100', 'SNFAD2-201-100-00000', 'SNFAD3-201-100-00000', 'SNFAD4-201-100-00000', 'SNFAD5-201-100-00000', 'SNFAD7-201-100-00000', 'SNFAP3-001-100-00000', 'SNFAP4-001-100-00000', 'SNFAP5-201-100-00000', 'SNFAP7-001-100-00000', 'SNFAP8-001-100-00000', 'SNFAP9-201-100-00000', 'SNFAPA-201-100-00000', 'SNFAPB-201-100-00000', 'SNFAPC-201-100-00000', 'SNFAPD-201-100-00000', 'SNFAPE-201-100-00000', 'SNFAPF-201-100-00000', 'SNFAPG-201-100-00000', 'SNFAPH-201-100-00000', 'SNFAPI-201-100-00000', 'SNFAPJ-201-100-00000', 'SNFAPK-201-100-00000', 'SNFAPL-201-100-00000', 'SNFAPM-201-100-00000', 'SNFAPN-201-100-00000', 'SNFAPO-201-100-00000', 'SNFAPP-201-100-00000', 'SNFAPQ-201-100-00000', 'SNFAPR-201-100-00000', 'SNFAR1-201-100', 'SNFAR2-201-100-00000', 'SNFAR3-201-100-00000', 'SNFAR4-201-100-00000', 'SNFAR5-201-100-00000', 'SNFARA-201-100-00000', 'SNFARB-201-100-00000', 'SNFARC-201-100-00000', 'SNFARD-201-100-00000', 'SNFARE-201-100-00000', 'SNFARF-201-100-00000', 'SNFARG-201-100-00000', 'SNFARH-201-100-00000', 'TFFAH1-201-100')

UNION
SELECT DISTINCT
op.ID
FROM tblOrders o
INNER JOIN tblOrders_Products op ON o.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppx ON op.ID = oppx.ordersProductsID
WHERE 
o.orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ', 'Delivered', 'In Transit', 'In Transit USPS', 'Waiting For Payment', 'On HOM Dock', 'On MRK Dock')
AND op.deleteX <> 'yes'
AND oppx.deleteX <> 'yes'
AND op.fastTrak_status = 'In House'
AND RIGHT(oppx.textValue, 2) = '_J')

INSERT INTO ArtGate (OPID, InsertedOn)
SELECT DISTINCT c.OPID, GETDATE()
FROM CTE c
LEFT JOIN ArtGate a ON c.OPID = a.OPID
WHERE a.OPID IS NULL