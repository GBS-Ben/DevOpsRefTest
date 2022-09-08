CREATE VIEW [dbo].[vwEntityLog]
AS 
SELECT el.LogID
	,EntityID
	,EntityType
	,LogType
	,LogInfo
	,LogDateTime
	,el.CreatedBy
	,el.CreatedOn
FROM tblEntityLog el
INNER JOIN tblEntityType et ON el.EntityTypeID = et.EntityTypeID
INNER JOIN tblEntityLogType elt ON el.LogTypeID  = elt.LogTypeID
LEFT JOIN tblEntityLogInfo eli ON el.LogID = eli.LogID