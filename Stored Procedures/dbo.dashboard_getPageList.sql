CREATE PROCEDURE [dbo].[dashboard_getPageList]

--starfall pmi

AS
SELECT PKID as ID, displayName as categoryName FROM dashboard_pageCategories
SELECT PKID, displayName, storedProcedure, categoryID, hidden FROM dashboard_pageList WHERE hidden = 0