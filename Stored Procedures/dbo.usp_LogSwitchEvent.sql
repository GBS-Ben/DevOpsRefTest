CREATE PROC [dbo].[usp_LogSwitchEvent] @FlowName VARCHAR(255) = NULL
	,@Job VARCHAR(255) = NULL
	,@EventName VARCHAR(255) = NULL
	,@PKID NVARCHAR(255) = NULL
	,@OPID NVARCHAR(255) = NULL
	,@eventData VARCHAR(max) = NULL
AS
BEGIN
	DECLARE @intPKID nvarchar(max)
	DECLARE @intOPID nvarchar(max)


	SET @pkid =  
		CASE 
			WHEN isNull(nullif(@PKID, ''), 'notFound') = 'notFound'
				THEN -1
			ELSE @PKID
			END

	SET @OPID =  CASE 
			WHEN isNull(nullif(@OPID, ''), 'notFound') = 'notFound'
				THEN -1
			ELSE @OPID
			END
	-- Every Value Is assigned as -1

	INSERT INTO dbo.tblSwitchEventLog (
		[flowName]
		,[PKID]
		,[ordersProductsID]
		,[eventName]
		,[eventTimestamp]
		,[jobName]
		,[eventData]
		)
	VALUES (
		@FlowName
		,@PKID
		,@OPID
		,@EventName
		,getdate()
		,@Job
		,@eventData
		)
END