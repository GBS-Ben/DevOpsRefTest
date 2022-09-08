/*
Script Purpose:
*/
    
CREATE PROCEDURE [dbo].[Report_CompanyList]
AS

SELECT CompanyId , cl.GbsCompanyId, CompanyName, ShortName, CONVERT(varchar(10),cl.CreateDate) AS [Setup Date],
CASE WHEN cl.IsActive = 1 THEN 'YES' ELSE 'NO' END AS IsActive,
CASE WHEN Published = 1 THEN 'YES' ELSE 'NO' END AS Published, 
CASE WHEN Deleted = 0 THEN 'YES' ELSE 'NO' END AS Deleted,
'https://www.markful.com/' + u.slug AS [Shop URL],

'https://classic.houseofmagnets.com/utilities/companydata/add-edit-company.aspx?companyId=' + CONVERT(nvarchar(1000),CompanyId)
AS [UtilityURL]

FROM sql01.nopcommerce.dbo.CompanyList cl WITH (NOLOCK)
LEFT JOIN sql01.nopCommerce.dbo.TblCompany c  WITH (NOLOCK) ON c.GbsCompanyId = cl.GbsCompanyId
LEFT JOIN sql01.nopCommerce.dbo.UrlRecord u  WITH (NOLOCK) ON u.EntityId = c.Id and u.Entityname = 'Company'
ORDER BY cl.CreateDate DESC