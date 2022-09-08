CREATE proc [dbo].[EntityLog_InsertAMZ]
 @EntityId NVARCHAR(30)
,@EntityType  varchar(255)
,@LogType varchar(255)
,@LogInfo varchar(max)
,@LogDateTime datetime
,@CreatedBy varchar(255)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SET @ENTITYID = CONVERT(INT, @ENTITYID)
		DECLARE  @LogID TABLE (LogID BIGINT, CreatedOn datetime);

		INSERT INTO tblEntityLog (EntityID,EntityTypeID,LogTypeID,LogDateTime,CreatedBy)
		OUTPUT inserted.LogID, inserted.CreatedOn INTO @LogID
		SELECT @EntityID, (SELECT EntityTypeID FROM tblEntityType WHERE EntityType = @EntityType), (SELECT LogTypeID FROM tblEntityLogType WHERE LogType = @LogType), @LogDateTime, @CreatedBy
		
		INSERT INTO tblEntityLogInfo (LogID, LogInfo, CreatedBy, CreatedOn)
		SELECT LogID, @LogInfo, @CreatedBy, CreatedOn
		FROM @LogID

	END TRY
	BEGIN CATCH

		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]

	END CATCH
END