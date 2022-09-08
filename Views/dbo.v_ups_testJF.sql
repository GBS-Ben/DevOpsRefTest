CREATE VIEW [dbo].[v_ups_testJF]
AS
-------------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     8/6/05
-- Purpose     This view is used by UPS Worldship for the Import Key. The data in this view is pulled into Worldship
 --			   when a 4 digit jobnumber is entered (v_ups.Unique_Identifier).
-------------------------------------------------------------------------------------
-- Modification History
-- 06/11/15		updated, jf.
-- 04/11/17		rewrite, jf.
-- 07/25/17		shreck.  dont exclude orders in jobtrack
-- 08/13/18		updated for new db, jf.
-------------------------------------------------------------------------------------

SELECT 
Unique_Identifier, Customer_ID, Company, Address_1, Address_2, City, [State], Zip, Country, Phone, [Service], Billing_Option, Attention, Email, noti_flag, 
From_Company, From_Address, From_City, From_State, From_Zip, From_Phone, From_Fax, From_Country, SpecialInstructions, fStoreID, fCompany, fAddress1, 
fCity, fState, fZip, fTollFree, fFax, fCSZ, totalBadgeWeight
FROM ScanShip