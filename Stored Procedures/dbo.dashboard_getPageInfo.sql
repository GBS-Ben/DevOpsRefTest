CREATE PROCEDURE "dbo"."dashboard_getPageInfo"
@pageID INT
AS
SELECT PKID,
	displayName,
	storedProcedure,
	categoryID,
	dataEditable,
	hidden,
	contentType
FROM dashboard_pageList
WHERE PKID = @pageID;