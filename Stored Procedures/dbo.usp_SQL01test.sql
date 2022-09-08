
CREATE PROC usp_SQL01test
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     08/3/16
-- Purpose     Pulls data from SQL01 to Dragonstone to determine up-time.
--			   Non-production			  
-------------------------------------------------------------------------------
-- Modification History
--
-- 01/19/17		create.
-------------------------------------------------------------------------------
AS

TRUNCATE TABLE CUSTOMER_TESTJF01_DND
INSERT INTO CUSTOMER_TESTJF01_DND ([Id], CustomerGuid, Username, Email, [Password], PasswordFormatId, PasswordSalt, AdminComment, IsTaxExempt, AffiliateId, VendorId, HasShoppingCartItems, Active, Deleted, IsSystemAccount, SystemName, LastIpAddress, CreatedOnUtc, LastLoginDateUtc, LastActivityDateUtc, BillingAddress_Id, ShippingAddress_Id)
SELECT [Id], CustomerGuid, Username, Email, [Password], PasswordFormatId, PasswordSalt, AdminComment, IsTaxExempt, AffiliateId, VendorId, HasShoppingCartItems, Active, Deleted, IsSystemAccount, SystemName, LastIpAddress, CreatedOnUtc, LastLoginDateUtc, LastActivityDateUtc, BillingAddress_Id, ShippingAddress_Id
FROM SQL01.nopCommerceDev.dbo.CUSTOMER 

DECLARE @jobRunID TINYINT

SET @jobRunID = (SELECT TOP 1 jobRunID
				FROM CUSTOMER_TESTJF01_DND_LOG
				ORDER BY runDate DESC)

SET IDENTITY_INSERT CUSTOMER_TESTJF01_DND_LOG ON
INSERT INTO CUSTOMER_TESTJF01_DND_LOG (jobRunID, runDate) SELECT 1 + @jobRunID, CURRENT_TIMESTAMP
SET IDENTITY_INSERT CUSTOMER_TESTJF01_DND_LOG OFF