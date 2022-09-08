CREATE PROCEDURE "dbo"."dashboard_test"
@oldEmail VARCHAR(50),
@newEmail VARCHAR(50)
AS
SELECT 'Success' AS 'Result',
CONCAT('Updated email ', @oldEmail, ' to ', @newEmail) AS 'Message'