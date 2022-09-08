CREATE PROC [dbo].[usp_RPT_migFailures]
AS
SELECT migStamp, COUNT(migStamp)
FROM tblMigLog
WHERE PKID IN
	(SELECT DISTINCT PKID - 1
	FROM tblMigLog
	WHERE migStamp = 'BEG')
GROUP BY migStamp
ORDER BY COUNT(migStamp) DESC