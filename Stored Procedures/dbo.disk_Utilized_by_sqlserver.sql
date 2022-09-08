CREATE PROCEDURE [dbo].[disk_Utilized_by_sqlserver]
AS
BEGIN
SET NOCOUNT ON;

	SET NOCOUNT ON

	DECLARE @list nvarchar(2000) = ''
	DECLARE @threshold decimal = 30.00 

		--Insanity for no DB Mail on SQL 01
		DECLARE @Disk TABLE(
		[Servername] varchar(100),
		[Disk Mount Point] varchar(100),
		[File System Type] varchar(100),
		[Logical Drive Name] varchar(100),
		[Total Size in GB] varchar(100),
		[Available Size in GB] varchar(100),
		[Space Free %] varchar(100)
		)
		INSERT @Disk
		EXECUTE HOMLive_disk_Utilized_by_sqlserver

		INSERT @Disk
		SELECT DISTINCT 
				'Winterfell' AS Servername,
				volume_mount_point [Disk Mount Point], 
				file_system_type [File System Type], 
				logical_volume_name as [Logical Drive Name], 
				CONVERT(DECIMAL(18,2),total_bytes/1073741824.0) AS [Total Size in GB], ---1GB = 1073741824 bytes
				CONVERT(DECIMAL(18,2),available_bytes/1073741824.0) AS [Available Size in GB],  
				CAST(CAST(available_bytes AS FLOAT)/ CAST(total_bytes AS FLOAT) AS DECIMAL(18,2)) * 100 AS [Space Free %] 
		FROM sys.master_files 
		CROSS APPLY sys.dm_os_volume_stats(database_id, file_id)


	SELECT @list = @list + ' ' + [Servername] + ' ' + [Disk Mount Point] + ', '
	FROM @Disk
	WHERE [Space Free %] < @threshold

	IF LEN(@list) > 3 BEGIN
		DECLARE @msg varchar(500) =  ' Low Disk Space Notification. The following drives are currently reporting less than ' 
		+ CAST(@threshold as varchar(12)) + '% Space Free : ' + @list
				
		EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Email',
		@recipients = 'sqlalerts@gogbs.com',
		@subject = 'Disk Alert - DO NOT IGNORE',
		@body = @msg
		
	END

	RETURN 0;

END