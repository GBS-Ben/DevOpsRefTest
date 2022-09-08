CREATE PROCEDURE [dbo].[usp_MIG_MISC]
AS
/*
-------------------------------------------------------------------------------
Author      Jeremy Fifer
Created     09/10/18
Purpose		Random procedures that need to run periodically go in here. 
			Eventually, this will be broken out into separate jobs.
-------------------------------------------------------------------------------
Modification History

09/13/18	Created, jf.
10/02/18	Pulled ArrivalDate calculation from this sproc and moved it to MIGHOMLIVE, jf.
10/02/18	Added popInvRunner here, jf.
12/05/18	Added OmniSearch, jf.
01/24/19	Added MIG_OPPO_PATCHER script, jf.
02/01/19	Added Proof section from MIG_HOMLIVE.
02/01/19	Added tblRatings section from MIG_HOMLIVE.
02/01/19	Added FT_MAINT section from MIG_HOMLIVE. This should be one of the first things ran after NOPLIVE runs.
02/01/19	Added usp_PopTrack section; used to exist in its own step in AGENT.
02/01/19	Added usp_orderView section; used to exist in its own step in AGENT.
02/19/19	Adding procedures to stop mig misc from running
09/11/19	JF, Removed a bunch of stuff and put them into their own jobs. I made a back of MIG_MISC dated today in case things go fubar.
11/20/19	JF, added ArtGate. See sproc for more details.
11/20/19	JF, added the File Exists Override section, which we should kill after Chad Bindl fixes his image checker.
12/14/20	CKB, iFrame conversion changes
03/02/21	JF, killed what i did on 11/20/19 for file exists
-------------------------------------------------------------------------------
*/
BEGIN TRY

-------------------------------------------------------------------ONLY RUN IF MIG_NOP RAN------------------------------------------
DECLARE @Run varchar(100), @y varchar(10),@LastRun datetime, @x varchar(10)
EXECUTE @x =  Migration_CheckMigMiscRun @Run output
EXECUTE @y = [dbo].[Setting_GetValue] 'MigMisc Last Run', @LastRun output

 IF @Run = '0' AND @LastRun > DATEADD(MI,-30, GETDATE())  --even if no new orders lets run this every 30 minutes
 BEGIN
	RETURN; --DO NOTHING
 END

--_________________________________________________________________________________________ UPDATE ORDERVIEW
--Updates the OrderView view that is used by the Intranet to view... orders.
--0 seconds

EXECUTE usp_orderView

--_________________________________________________________________________________________ MIG OPPO PATCHER SCRIPT
--patches NOP tblOrdersProducts_productOptions
--2 seconds

EXECUTE MIG_OPPO_PATCHER

----_________________________________________________________________________________________ OPPO EMAILS
--0 seconds

EXECUTE usp_OPPO_email


----_________________________________________________________________________________________ ART GATE
--0 seconds 

EXECUTE popArtGate

--_________________________________________________________________________________________ EXPRESS PRODUCTION Update
--0 seconds

UPDATE a
SET a.specialInstructions = LEFT('Express Production: Must arrive by ' + CONVERT(NVARCHAR(50), DATEPART(MM, a.arrivalDate)) + '/' + CONVERT(NVARCHAR(50), DATEPART(DD, a.arrivalDate)) + '/' + CONVERT(NVARCHAR(50), DATEPART(YY, a.arrivalDate)) + '.  ' + ISNULL(a.specialInstructions, ''), 499)
FROM tblOrders a
INNER JOIN tblOrders_Products op
	ON a.orderID = op.orderID
INNER JOIN tblOrdersProducts_productOptions oppo
	ON op.ID = oppo.ordersProductsID
WHERE oppo.deleteX <> 'yes'
AND oppo.optionCaption = 'Express Production'
AND (optionCaption = 'Express Production' AND (textValue LIKE 'Yes%' OR textValue LIKE 'Express%' OR ISNULL(textValue,'') = ''))	-- added textValue qualifier for iFrame conversion
AND a.arrivalDate IS NOT NULL
AND a.specialInstructions NOT LIKE 'Express Production%'
AND a.orderStatus NOT IN ('Delivered', 'Failed', 'Cancelled')

--_________________________________________________________________________________________ Extra Fun Things

DECLARE @Date varchar(100) = CONVERT(varchar(100), GETDATE(),13)
--MIG MISC SHOULD RUN
EXECUTE Setting_Update 'Run MigMisc' , '0'  --Nothing for mig Misc to do
EXECUTE Setting_Update 'MigMisc Last Run' , @Date  --Nothing for mig Misc to do

--_________________________________________________________________________________________ Ask Jeremy. This is dumb.

UPDATE tblOrders_Products
SET fastTrak_status = 'In House'
WHERE fastTrak_status = 'ready'

--_________________________________________________________________________________________ File Exists Override
--Some images that our file checker checks for, never exist (e.g., \\arc\archives\webstores\OPC\1_-1.pdf).
--This code marks them as existing so that the associated OPIDs can get enter the fasTrak flow.

-- KILLED THIS 02MAR2021, JF.
														--UPDATE x
														--SET fileExists = 1,
														--isFlattened = 1,
														--readyForSwitch = 1,
														--readyForSwitchDate = GETDATE()
														--FROM tblOPPO_fileExists x 
														--INNER JOIN tblOrders_Products op ON x.opid = op.id
														--INNER JOIN tblOrders o ON op.orderid = o.orderID
														--WHERE EXISTS
														--	(SELECT TOP 1 1
														--	FROM tblOPPO_fileExists z
														--	WHERE textValue LIKE '%GetHiRes%'
														--	AND fileExists = 0
														--	AND z.opid = x.opid)
														--AND op.deletex <> 'yes'
														--AND x.fileExists = 0


END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXECUTE [dbo].[usp_StoredProcedureErrorLog]

END CATCH