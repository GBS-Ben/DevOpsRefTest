




CREATE VIEW [dbo].[vwCompanyUrl]
AS
SELECT TRIM(c.Name) AS Name, 'https://www.markful.com/'+u.slug AS URL
  FROM nopCommerce_UrlRecord u
  INNER JOIN nopCommerce_tblcompany c on u.entityID = c.id AND u.entityname = 'Company'