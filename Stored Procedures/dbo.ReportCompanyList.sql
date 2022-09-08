-- =============================================
-- exec dbo.ReportCompanyList
-- =============================================
CREATE PROCEDURE [dbo].[ReportCompanyList]
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT CompanyID=c.ID, CompanyName=c.Name, c.CompanyShortCode, c.GBSCompanyID, c.Published, c.Deleted, c.ParentCompanyID, ParentGBSCompanyID=PC.GBSCompanyID
	FROM dbo.nopcommerce_tblcompany c
	LEFT JOIN dbo.nopcommerce_tblcompany PC ON PC.ID=C.ParentCompanyID
	ORDER BY 2
END