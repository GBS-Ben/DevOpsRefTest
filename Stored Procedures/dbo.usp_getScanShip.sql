CREATE PROCEDURE [dbo].[usp_getScanShip]
@UID NVARCHAR(20)
AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		08/22/2018
-- Purpose		This proc is called by shipping stations to populate scan.

-------------------------------------------------------------------------------
-- Modification History
--
-- 8/22/18		Created, JF
-------------------------------------------------------------------------------

SELECT 
Unique_Identifier, Customer_ID, Company, Address_1, Address_2, City, [State], Zip, Country, Phone, [Service], Billing_Option, Attention, Email, noti_flag, 
From_Company, From_Address, From_City, From_State, From_Zip, From_Phone, From_Fax, From_Country, SpecialInstructions, fStoreID, fCompany, fAddress1, 
fCity, fState, fZip, fTollFree, fFax, fCSZ, totalBadgeWeight
FROM ScanShip 
WHERE Unique_Identifier = @UID