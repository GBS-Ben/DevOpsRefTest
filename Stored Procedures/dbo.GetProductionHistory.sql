CREATE PROCEDURE [dbo].[GetProductionHistory] 
	@OPID INT
AS
BEGIN

	DECLARE @workflowID INT;
	SET @workflowID = (SELECT workflowID FROM tblOrders_Products WHERE ID = @OPID);

	WITH cteWP AS (
		SELECT processName,stepNumber,wpid,workflowid,opp.runnumber
		FROM [gbsController].[dbo].[vwWorkflowProcess] wp
		CROSS APPLY (SELECT DISTINCT runnumber FROM gbsCore.dbo.tblopidproductionprocess WHERE opid = @opid) opp
		WHERE workflowid = @workflowid
	)
	SELECT 
		 wp.runnumber AS 'RunNumber'
		,wp.stepNumber AS 'StepNumber'
		,wp.processName AS 'ProcessName'
		,CASE WHEN completed_Status <> 'Success' THEN 'Fail'
			WHEN created_on IS NOT NULL AND completed_On IS NULL THEN 'In Progress' 
			WHEN completed_status = 'success' THEN 'Complete' ELSE '' END AS 'Status'
		,ISNULL(CAST(created_On AS VARCHAR(25)),'') AS 'StartDate'
		,ISNULL(CAST(completed_On AS VARCHAR(25)),'') AS 'CompletionDate'
	--	,ISNULL(CAST(completed_status AS VARCHAR(25)),'') AS 'CompletionStatus'
	  FROM ctewp wp
	  LEFT JOIN gbscore.dbo.tblopidproductionprocess opp ON wp.workflowid = opp.workflowid AND wp.wpid= opp.wpid AND opp.opid= @opid AND wp.runnumber = opp.runnumber
		WHERE wp.workflowid = @workflowid
	  ORDER BY wp.runnumber desc,wp.stepnumber;
END;