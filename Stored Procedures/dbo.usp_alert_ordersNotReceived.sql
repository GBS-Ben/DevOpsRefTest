CREATE PROC [dbo].[usp_alert_ordersNotReceived]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     11/1/17
-- Purpose     Notifies email recipient when orders are not being received.
-------------------------------------------------------------------------------
-- Modification History
--
-- 11/1/17		New
-- 11/14/17		Modified messages, jf.
-- 12/14/20		BS, modified to include check of nop user activity
-- 12/19/20		BS, modified to be less chatty on weekends and holidays
-------------------------------------------------------------------------------

--declare and set
DECLARE @mostRecentOrderDate DATETIME = '01/01/1974',
				@timeDifferenceInSeconds INT = 0, 
		@UserActivityCount int,
		@AlertElapsedTimeinSeconds int = 1800,  --this is the default time, weekends and holidays will be much greater
		@HighAlertElapsedTimeinSeconds int = 3600,
		@BodyMessage nvarchar(2000) = '',
		@SubjectMessage nvarchar(1000) = '',
		@HolidayWeekend int = 0


IF (SELECT CASE WHEN IsWeekend = 1 THEN 1
	WHEN isHoliday = 1 THEN 1
	ELSE 0 
	END AS OffHours 
	FROM DateDimension WHERE DateKey = CONVERT(int,CONVERT(nvarchar(8),GETDATE(),112))) =1 
BEGIN 
	SET @HolidayWeekend = 1
	SET @AlertElapsedTimeinSeconds = 7200  -- Hours for alert
	SET @HighAlertElapsedTimeinSeconds = 14400  -- 4 hours for high alert.  
END

SET @mostRecentOrderDate = (SELECT TOP 1 orderDate	FROM tblOrders ORDER BY orderDate DESC)
SET @timeDifferenceInSeconds = (SELECT DATEDIFF(SS, @mostRecentOrderDate, GETDATE()))
SET @UserActivityCount = (
					SELECT TOP 1 1 
					FROM dbo.nopcommerce_Customer  c
					WHERE DATEDIFF(mi, LastActivityDateUtc, GETUTCDATE()) < CASE WHEN @HolidayWeekend = 0 THEN 30 ELSE 120 END --				
					ORDER BY LastActivityDateUtc desc	
						) 
--only look at 0600 thru 1900 time slots (6am - 9pm EST)
--if most recent order is > alerttime minutes (or longer) ago, then fire away
IF DATEPART(HH,GETDATE()) >= 6 AND DATEPART(HH,GETDATE()) <= 19
BEGIN
	 IF @timeDifferenceInSeconds >= @AlertElapsedTimeinSeconds
		 AND @timeDifferenceInSeconds < @HighAlertElapsedTimeinSeconds
	 BEGIN
		SET @BodyMessage = (SELECT 'Neo.

						We haven''t received any orders in the last ' +  CASE WHEN @HolidayWeekend = 1 THEN '2 Hours' ELSE '30 Minutes' END  + '. Depending on the time of day, this could be an issue. Another email fires if orders aren''t received within an hour, so be on the lookout for that.

						Orders are only checked 0600 thru 1900 time slots (6am - 9pm EST).

						Be Alert, 
						Morpheus')
		SET @SubjectMessage = (SELECT 'ALERT - No orders received for at least ' +  CASE WHEN @HolidayWeekend = 1 THEN '2 Hours' ELSE '30 Minutes' END  + '.')

		
		--exec sp_send_cdosysmailtxt 'GBS.SQL@gogbs.com', 'jeremy@gogbs.com', 'SQL Alert - No orders received in last 30 minutes [BLUE PILL]', 
		EXEC msdb.dbo.sp_send_dbmail
				@profile_name = 'SQLAlerts',
				@recipients = 'jeremy@gogbs.com; cbrowne@gogbs.com; sqlalerts@gogbs.com;8588294317@vtext.com;6039917472@tmomail.net',
				@body = @BodyMessage,
			--	@body_format ='HTML',
				@subject = @SubjectMessage 


		END
	
	
	 IF @timeDifferenceInSeconds >= @HighAlertElapsedTimeinSeconds
	 BEGIN
		--exec sp_send_cdosysmailtxt 'GBS.SQL@gogbs.com', 'jeremy@gogbs.com', 'SQL Alert - No orders received for at least an hour [RED PILL]', 
		
		SET @BodyMessage = (SELECT 'Neo.

					We haven''t received any orders in the last ' +  CASE WHEN @HolidayWeekend = 1 THEN '4' ELSE '1' END + ' hour. Unless it is a holiday or an early weekend morning, this is likely an issue.

					Orders are only checked 0600 thru 1900 time slots (6am - 9pm EST).

					Fix things.

					Trinity')
		SET @SubjectMessage = (SELECT 'RED ALERT - No orders received for at least ' +  CASE WHEN @HolidayWeekend = 1 THEN '4' ELSE '1' END  + '  hours')

							EXEC msdb.dbo.sp_send_dbmail
									@profile_name = 'SQLAlerts',
									@recipients = 'jeremy@gogbs.com; cbrowne@gogbs.com;sqlalerts@gogbs.com;8588294317@vtext.com;6039917472@tmomail.net',
									@body = @BodyMessage,
								--	@body_format ='HTML',
									@subject = @SubjectMessage 


		END

	 IF @UserActivityCount < 1
	 BEGIN
	
							EXEC msdb.dbo.sp_send_dbmail
									@profile_name = 'SQLAlerts',
									@recipients = 'jeremy@gogbs.com;cbrowne@gogbs.com;sqlalerts@gogbs.com;8588294317@vtext.com;6039917472@tmomail.net',
									@body = 'We haven''t received customer activity on NOP. Don''t ignore me. Load the website and place a test order to check it out.',
								--	@body_format ='HTML',
									@subject = 'NOP ALERT - No customer activity on NOP.  Check the website.'
		END
END