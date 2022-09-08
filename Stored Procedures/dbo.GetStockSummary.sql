

CREATE PROC [dbo].[GetStockSummary]  
	@WhereClause varchar(2000) 
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		
		DROP TABLE IF EXISTS #temp
		SELECT * INTO #temp FROM vwOPIDInventory

		SET NOCOUNT OFF

		SELECT catalogno,gender,color,ov.SIZE,SUM(productquantity) AS neededQty,MIN(availableQuantity) AS availableQty,MIN(pendingQuantity) AS pendingQty 
		FROM vwOPIDViewWithOppo ov
		INNER JOIN #temp t on ov.ID = t.OPID
		WHERE ov.ID IN (SELECT value FROM STRING_SPLIT(replace(@WhereClause,'''',''), ',') )
		GROUP BY catalogno,gender,color,ov.SIZE 
		ORDER BY catalogno,gender,color,CASE ov.SIZE WHEN 'XS' THEN 1 WHEN 'small' THEN 2 WHEN 'medium' THEN 3 WHEN 'large' THEN 4 WHEN 'XL' THEN 5 WHEN '2XL' THEN 6 WHEN '3XL' THEN 7 WHEN '4XL' THEN 8 WHEN '5XL' THEN 9 ELSE 0 END
	END TRY
	BEGIN CATCH
		DECLARE @err VARCHAR(255) = 'GetStockSummary - ' + ERROR_MESSAGE()
		RAISERROR (@err,11,1);
		--Capture errors if they happen
		EXEC [dbo].[usp_StoredProcedureErrorLog]
	END CATCH


END