CREATE PROC [dbo].[usp_SwitchLogTron]
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/03/18
-- Purpose     Retrieves most recent switch run; then remaining rows from BC Switch Log.
-------------------------------------------------------------------------------
-- Modification History
--07/02/18	created, jf.
-------------------------------------------------------------------------------

DECLARE @countSimplex_MRR INT = 0,
				@countDuplex_MRR INT = 0

SET @countSimplex_MRR = (SELECT COUNT(PKID)
												FROM tblSwitch_BC_LOG_TRON
												WHERE logDate =  (SELECT TOP 1 logDate
																				FROM tblSwitch_BC_LOG_TRON
																				WHERE SUBSTRING(dataVersion, 1, 7) = 'Simplex'
																				ORDER BY logDate DESC)
											)


SET @countDuplex_MRR = (SELECT COUNT(PKID)
												FROM tblSwitch_BC_LOG_TRON
												WHERE logDate =  (SELECT TOP 1 logDate
																				FROM tblSwitch_BC_LOG_TRON
																				WHERE SUBSTRING(dataVersion, 1, 6) = 'Duplex'
																				ORDER BY logDate DESC)
											)

PRINT @countSimplex_MRR
PRINT @countDuplex_MRR

SELECT 'most recent simplex run: ' + CONVERT(NVARCHAR(10), @countSimplex_MRR) AS 'a', * 
FROM tblSwitch_BC_LOG_TRON
WHERE logDate =  (SELECT TOP 1 logDate
								FROM tblSwitch_BC_LOG_TRON
								WHERE SUBSTRING(dataVersion, 1, 7) = 'Simplex'
								ORDER BY logDate DESC)

UNION ALL

SELECT 'most recent duplex run: ' + CONVERT(NVARCHAR(10), @countDuplex_MRR) AS 'a', * 
FROM tblSwitch_BC_LOG_TRON
WHERE logDate =  (SELECT TOP 1 logDate
								FROM tblSwitch_BC_LOG_TRON
								WHERE SUBSTRING(dataVersion, 1, 6) = 'Duplex'
								ORDER BY logDate DESC)

UNION ALL
SELECT 'older runs: ' AS 'a', *
FROM tblSwitch_BC_LOG_TRON
WHERE logDate NOT IN
								(SELECT TOP 1 logDate
								FROM tblSwitch_BC_LOG_TRON
								WHERE SUBSTRING(dataVersion, 1, 7) = 'Simplex'
								ORDER BY logDate DESC)
AND logDate NOT IN
								(SELECT TOP 1 logDate
								FROM tblSwitch_BC_LOG_TRON
								WHERE SUBSTRING(dataVersion, 1, 6) = 'Duplex'
								ORDER BY logDate DESC)
ORDER BY a, logDate DESC, dataversion DESC, pkid