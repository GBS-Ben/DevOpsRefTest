CREATE PROC [dbo].[usp_getJobTrack]
@orderNo VARCHAR(50)
AS
-------------------------------------------------------------------------------
-- Author		Jeremy Fifer
-- Created		07/28/2016
-- Purpose		Grabs full table of shipping data per orderNo submitted.
--					Used on orderView.asp in the Intranet, via "GET SHIP" button.

-------------------------------------------------------------------------------
-- Modification History
-- CT 4/21/2019 Adjusting Intranet 'Shipping history' button Column Sorting
--  + Adding UpdatedOn Column to SELECT STATEMENT
-------------------------------------------------------------------------------
SELECT
[UpdatedOn], [jobNumber], [trackingNumber], [mailClass], [pickup date], [scheduled delivery date],[ups service],
[package count], [subscription file name], [trackSource], [weight], [PKID], [addtrack], 
[Delivery Street Number], [Delivery Street Prefix], [Delivery Street Name], 
[Delivery Street Type], [Delivery Street Suffix], [Delivery Building Name], [Delivery Room/Suite/Floor], 
[Delivery City], [Delivery State/Province], [Delivery Postal Code], [deliveredOn], [location], [signedForBy], 
[addressType_DisplayOnIntranet], [addressType], [postageAmount], [postMarkDate], [transactionID], [transactionDate]
FROM tblJobTrack 
WHERE jobNumber = @orderNo
ORDER BY UpdatedON DESC