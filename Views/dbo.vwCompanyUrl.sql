CREATE VIEW [dbo].[vwCompanyUrl]
AS
SELECT TRIM(c.Name) AS Name, 'https://www.markful.com/'+u.slug AS URL
  FROM dbo.nopCommerce_UrlRecord u
  INNER JOIN dbo.nopCommerce_tblcompany c on u.entityID = c.id AND u.entityname = 'Company'