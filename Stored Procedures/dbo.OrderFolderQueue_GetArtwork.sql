CREATE PROC [dbo].[OrderFolderQueue_GetArtwork]
@folderGUID varchar(255) ,
@optionJSON varchar(8000),
@status VARCHAR(255) OUTPUT,
@errMsg NVARCHAR(4000) OUTPUT
AS
BEGIN
	BEGIN TRY
		

		DECLARE @delimiter as varchar(2) = ','
		DECLARE @images as nvarchar(4000)
		CREATE TABLE #temp
			(imagename varchar(255) NOT NULL);
		SET @images = (SELECT textvalue as 'images'
						FROM OPENJSON(@optionJSON)
							WITH (
								[optioncaption] [varchar](255),
								[textvalue] [nvarchar](400))
						WHERE optioncaption = 'artwork')

		IF @images LIKE '%' + @Delimiter + '%'
		BEGIN
			WITH CTE_CSV_SPLIT AS (
				SELECT
					CAST(1 AS INT) AS Data_Element_Start_Position,
					CAST(CHARINDEX(@Delimiter, @images) - 1 AS INT) AS Data_Element_End_Position
				UNION ALL
				SELECT
					CAST(CTE_CSV_SPLIT.Data_Element_End_Position AS INT) + LEN(@Delimiter),
					CASE WHEN CAST(CHARINDEX(@Delimiter, @images, CTE_CSV_SPLIT.Data_Element_End_Position + LEN(@Delimiter) + 1) AS INT) <> 0
							THEN CAST(CHARINDEX(@Delimiter, @images, CTE_CSV_SPLIT.Data_Element_End_Position + LEN(@Delimiter) + 1) AS INT)
							ELSE CAST(LEN(@images) AS INT)
					END AS Data_Element_End_Position
				FROM CTE_CSV_SPLIT
				WHERE (CTE_CSV_SPLIT.Data_Element_Start_Position > 0 AND CTE_CSV_SPLIT.Data_Element_End_Position > 0 AND CTE_CSV_SPLIT.Data_Element_End_Position < LEN(@images)))
			INSERT INTO #temp
				(imagename)
			SELECT
				ltrim(REPLACE(SUBSTRING(@images, Data_Element_Start_Position, Data_Element_End_Position - Data_Element_Start_Position + LEN(@Delimiter)), @Delimiter, '')) AS Column_Data
			FROM CTE_CSV_SPLIT
			OPTION (MAXRECURSION 32767);
		END
		ELSE
		BEGIN
			INSERT INTO #temp
				(imagename)
			SELECT @images;
		END
		SELECT * FROM #temp;


	END TRY
	BEGIN CATCH
		
		SELECT @status = 'Fail', @errMsg = ERROR_MESSAGE();

		-- Log error status
		UPDATE t SET processEndDateTime=GETDATE(),processStatus = @status, processError=@errMsg
		FROM [dbo].[tblOrderFolderLog] t
		WHERE FolderGUID = @folderGUID

	END CATCH
END