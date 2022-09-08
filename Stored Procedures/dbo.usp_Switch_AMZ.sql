CREATE PROCEDURE [dbo].[usp_Switch_AMZ] 
AS
/*
-------------------------------------------------------------------------------
Author      Jonathan Bentley	
Created     03/07/22
Purpose     Amazon 24 count NC into Switch for production.
-------------------------------------------------------------------------------
Modification History

03/07/22		New - modeled from usp_Switch_NBS
-------------------------------------------------------------------------------
*/

DECLARE @lastRunDate datetime = getdate();
EXEC ProcessStatus_Update 'AMZ Switch SP', @lastRunDate;



BEGIN TRY

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FLAG
---- Flags
--DECLARE @Flag BIT
--SET @Flag = (SELECT FlagStatus FROM Flags WHERE FlagName = 'ImposerAMZ')
					   
----IF @Flag = 0
----BEGIN
--UPDATE Flags
--SET FlagStatus = 1
--WHERE FlagName = 'ImposerAMZ'

--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// FILE EXISTS


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// CREATE MAIN QUERY
IF OBJECT_ID('tempdb..#tblSwitch_AMZ') IS NOT NULL 
DROP TABLE #tblSwitch_AMZ
CREATE TABLE #tblSwitch_AMZ (
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AMZID] [int] NOT NULL,
	[PKID] [nvarchar](255) NULL,
	[orderID] [nvarchar](255) NULL,
	[orderNo] [nvarchar](255) NULL,
	[orderDate] [datetime] NULL,
	[productCode] [nvarchar](50) NULL,
	[productName] [nvarchar](255) NULL,
	[productQuantity] [int] NULL,
	[variableWholeName] [nvarchar](MAX) NULL,
	[variableBackName] [nvarchar](MAX) NULL,
	[ordersProductsID] [bigint] NULL,
	[resubmit] [bit] NULL,
	[switch_create] [bit] NULL,
	[switch_createDate] [datetime] NULL,
	[width] [Decimal](8,3) NULL,
	[height] [Decimal](8,3) NULL,
	[bleed] [Decimal](8,3) NULL,
	[stock][nvarchar](255) NULL,
	[Grain_Direction][nvarchar](255) NULL,
	[grade][nvarchar](255) NULL,
	[Max_Overruns][nvarchar](255) NULL,
	[Die_Design_Name][nvarchar](255) NULL,
	[Cad_File][nvarchar](255) NULL,
	[Die_Design_Source][nvarchar](255) NULL,
	[Description][nvarchar](255) NULL,
	[Marks][nvarchar](255) NULL)

INSERT INTO #tblSwitch_AMZ (AMZID, PKID, orderID, orderNo, orderDate,
productCode, productName, productQuantity, 
variableWholeName, 
variableBackName,  
ordersProductsID, 
resubmit,  
switch_create, switch_createDate, width,
height, bleed, stock, Grain_Direction,
grade, Max_Overruns, Die_Design_Name,
Cad_file, Die_Design_Source, [Description], Marks)

SELECT
ID, PKID,[order-id],orderNo,[purchase-date],
sku,[product-name],[quantity-purchased],
'\\SUMMERHALL\MERGE CENTRAL\Amazon_NC_Print\Individual NCC Cards\' + sku + '.pdf' AS Front_Artwork_File,
'' AS Back_Artwork_File,
[order-item-id],
fastrak_resubmit,
switch_create,
switch_createDate,
CAST(6.125 AS DECIMAL(8,3)) AS Width,
CAST(9.125 AS DECIMAL(8,3)) AS Height,
CAST(.125 AS DECIMAL(8,3)) AS Bleed,
'15 point C1s' AS Stock,
'' AS Grain_Direction,
'' AS grade,
'' AS Max_Overruns,
'A6 NC Die' AS Die_Design_Name,
'' AS Cad_File,
''AS Die_Design_Source,
''AS [Description],
'' AS Marks
  FROM tblAMZ_orderValid ov
  --1. Order Qualification ----------------------------------
  WHERE ISNULL(Sku,'') <> ''
  AND DATEDIFF(MI,[purchase-date], GETDATE()) > 60  --increase the time so Calendars and FB have time to load in
  AND orderStatus NOT IN ('Failed', 'Cancelled', 'MIGZ')
  --2. Product Qualification ----------------------------------
  AND sku LIKE 'NC%'
  AND [product-name] LIKE '%24%'
  AND [product-name] NOT LIKE '%72%'
  --3. New / Resubmit----------------------------------------------
  AND (
	  switch_create = 0 
	  OR fasTrak_resubmit = 1
	  )


--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// OTHER STUFF
----Set flag back to '0'.
--UPDATE Flags
--SET FlagStatus = 0
--WHERE FlagName = 'ImposerAMZ'


--Step to log current batch of OPID/Punits
declare @CurrentDate datetime = getdate() --Get current date for batch
insert into dbo.tblSwitchBatchLog(flowName,PKID,ordersProductsID,batchTimestamp,jsonData)
select 
flowName = 'AMZ'
,a.ID
,a.AMZID
,batchTimestamp = @CurrentDate
,jsonData = 
       (select *
       from #tblSwitch_AMZ b
       where a.PKID = b.PKID
       for json path)
from #tblSwitch_AMZ a

-- Update OPID status fields indicating successful submission to switch
UPDATE op
SET switch_create = 1,
	--fastTrak_status = 'In House',
	--TALK TO BRIAN!!!--
	---------------------------------------
		--orderStatus = 'In Production',
	---------------------------------------
	lastStatusUpdate = GETDATE(),
	fasTrak_resubmit = 0
FROM tblAMZ_orderValid op
INNER JOIN #tblSwitch_AMZ q ON op.PKID = q.PKID
--////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// OUTPUT

SELECT *
FROM #tblSwitch_AMZ 
ORDER BY OrderNo ASC

END TRY
BEGIN CATCH
	EXEC [dbo].[usp_StoredProcedureErrorLog]
END CATCH