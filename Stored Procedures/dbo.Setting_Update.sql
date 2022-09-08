

CREATE PROCEDURE Setting_Update
	@Name nvarchar(500), 
	@Value nvarchar(max)
AS

UPDATE SETTING 
SET [value] = @Value
WHERE [Name] = @Name