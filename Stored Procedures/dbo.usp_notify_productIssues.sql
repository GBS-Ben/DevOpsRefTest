CREATE PROCEDURE [dbo].[usp_notify_productIssues]
AS

--this proc notifies users via email that there are issues with the internal product numUnits and/or parentProductID setup.

declare @counter_numUnits int = 0,
@counter_PPID int = 0,
--these are email-centric variables:
@bodytext varchar(8000),
@subjecttext varchar(255),
@recipient varchar(255),
@email varchar(255)

--set counter vars
set @counter_numUnits=(select count(distinct(productID)) from tblProducts where numUnits = 1 AND productName LIKE '%SPECIAL%' AND productName like '%PACK%')

if @counter_numUnits is NULL
BEGIN
set @counter_numUnits = 0
END

set @counter_PPID=(select count(distinct(productID)) from tblProducts where productName LIKE '%SPECIAL %' 
								AND productID = parentProductID 
								AND productID > 160000 
								AND productID < 310000
								AND productName NOT LIKE '%BADGE%'
								AND productName NOT LIKE '2011%'
								AND productName NOT LIKE '2012%'
								AND productName NOT LIKE '2013%'
								AND productName NOT LIKE '2014%'
								AND productName NOT LIKE '2015%'
								AND productName NOT LIKE '2016%'
								AND productName NOT LIKE '2017%'
								AND productName NOT LIKE '%Special Gift%'
								AND productName NOT LIKE '%Special Day%'
								)

if @counter_PPID is NULL
BEGIN
set @counter_PPID = 0
END

-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL BEGIN
IF @counter_numUnits <> 0
BEGIN

	--set email vars
	set @subjecttext=''+convert(varchar(255),@counter_numUnits)+' numUnits issues found in tblProducts'

	set @bodytext='
	There are '+convert(varchar(255),@counter_numUnits)+' numUnits issues found in tblProducts.  Fix them.'

	set @email='jeremy@gogbs.com'

					--send email
	EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'SQLAlerts',
				@recipients = @email,
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText
END
-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL END

-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL-- EMAIL BEGIN
IF @counter_PPID <> 0
BEGIN

--set email vars
set @subjecttext=''+convert(varchar(255),@counter_PPID)+' PPID issues found in tblProducts'

set @bodytext='
There are '+convert(varchar(255),@counter_PPID)+' PPID issues found in tblProducts.  Fix them.'

set @email='jeremy@gogbs.com, bobby@gogbs.com'

				--send email
	EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'SQLAlerts',
				@recipients = @email,
				@body = @bodyText,
			--	@body_format ='HTML',
				@subject = @subjectText
END