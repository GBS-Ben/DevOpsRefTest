CREATE PROCEDURE AMZ_ImportCustomizedInfoJSON
	@orderitemid varchar(100)
AS
BEGIN
/*
-------------------------------------------------------------------------------
-- Author      Bobby Shreckengost
-- Created     10/25/2018
-- Purpose     Ingests the contents of a json  file into the amazon order item
--				Customized info table.
-------------------------------------------------------------------------------

*/



	 DECLARE @json nvarchar(max)

	 --always use the same file name because i wasnt smart enough to make it a parameter.  The ssis package will
	 --rename the file.  Someday this should probably just be added to a web service
	 SELECT  @json = BulkColumn FROM OPENROWSET (BULK 'F:\httpfiles\unzip\customizedinfo.json', SINGLE_CLOB) as j


	 INSERT [dbo].[tblAMZ_CustomizedInfoJSON] ( [order-item-id], [BuyerCustomizedInfoJSON])
	 VALUES (@orderitemid, @json) 
	 

 END