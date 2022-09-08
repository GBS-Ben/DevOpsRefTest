-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[GetInventoryProduct]
	@SqlWhere nvarchar(1024)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @SQLStatement nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);
	
	set @SQLStatement = N' 
	      SELECT  a.ProductId 
	     FROM tblProducts a  where  a.productname NOT LIKE ''%SPECIAL%''  AND (a.parentProductID = a.productID OR a.parentProductID IS NULL OR a.parentProductID = '''') 
	 
	     '+@SqlWhere;
	   	    
	   EXEC( @SQLStatement);	
	  
	   END