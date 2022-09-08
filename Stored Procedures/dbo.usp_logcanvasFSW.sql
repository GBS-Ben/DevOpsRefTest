CREATE PROC [dbo].[usp_logcanvasFSW] 
	 @parent NVARCHAR(255)
	,@stateFile NVARCHAR(255)
	,@CreatedOn NVARCHAR(255)
	,@Fullpath NVARCHAR(255)
	,@valid NVARCHAR(255)

AS
BEGIN
	--DECLARE @intPKID nvarchar(max)
	--DECLARE @intOPID nvarchar(max)


	--SET @pkid =  
	--	CASE 
	--		WHEN isNull(nullif(@PKID, ''), 'notFound') = 'notFound'
	--			THEN -1
	--		ELSE @PKID
	--		END

	--SET @OPID =  CASE 
	--		WHEN isNull(nullif(@OPID, ''), 'notFound') = 'notFound'
	--			THEN -1
	--		ELSE @OPID
	--		END
	---- Every Value Is assigned as -1

	INSERT INTO dbo.tblCanvasFSW (
[parent]
,[StateFile]
,[createdOn]
,[FullPath]
,[valid]
		)
	VALUES (		
 @parent
,@stateFile
,try_convert(datetime,@Createdon)
,@Fullpath
,try_convert(bit,@valid)
)
END