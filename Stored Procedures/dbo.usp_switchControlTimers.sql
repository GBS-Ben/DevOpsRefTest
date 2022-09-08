CREATE PROCEDURE "dbo"."usp_switchControlTimers"

AS

update tblSwitchControl
set controlStatus = 1
where PKID IN (
	SELECT PKID from tblSwitchControl
	WHERE autoTriggerHour = DATEPART(HOUR, GETDATE()) -- if current hour matches defined trigger time
	AND lastCheckedHour <> DATEPART(HOUR, GETDATE()) -- and if we haven't checked already this hour. This prevents duplicate updates from mutiple triggers within the same hour.
);

-- update lastCheckedHour so that if we run again this hour, it won't cause another update.
update tblSwitchControl 
set lastCheckedHour = DATEPART(HOUR, GETDATE())