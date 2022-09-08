





CREATE PROC [dbo].[GetProductionOPID] @workflowID INT = NULL, @tabSelected varchar(255) = NULL
AS
BEGIN
	SET NOCOUNT ON

	IF @workflowID IS NULL 
	BEGIN 
		SELECT DISTINCT workflowName,intranetTab,processName,ow.OPID,ow.created_On,ow.completed_status,ov.*
			,CASE WHEN completed_Status <> 'Success' THEN 'Fail'
				WHEN ow.created_on IS NOT NULL AND completed_On IS NULL THEN 'In Progress' 
				WHEN completed_status = 'success' THEN 'Complete' ELSE '' END AS 'Status'
		FROM vwOPIDCurrWorkflowall ow
		LEFT JOIN vwOPIDViewall ov on ow.OPID = ov.ID
		WHERE OPID IS NOT NULL
		  AND isActive = 1
		  AND completed_On is NULL
		ORDER BY OPID DESC
	END
	ELSE IF @tabSelected IS NOT NULL 
	BEGIN 
		IF @tabSelected = 'Failures' 
		BEGIN
			SELECT DISTINCT workflowName,intranetTab,processName,ow.OPID,ow.created_On,ow.completed_status,ov.*
			,CASE WHEN completed_Status <> 'Success' THEN 'Fail'
				WHEN ow.created_on IS NOT NULL AND completed_On IS NULL THEN 'In Progress' 
				WHEN completed_status = 'success' THEN 'Complete' ELSE '' END AS 'Status'
			FROM vwOPIDCurrWorkflowALL ow
			LEFT JOIN vwOPIDViewAll ov on ow.OPID = ov.ID
			WHERE ow.workflowid = @workflowID
			  AND ow.completed_Status = 'Fail' AND isActive = 1
			  and OPID IS NOT NULL
			ORDER BY OPID DESC
		END
		IF @tabSelected = 'Stock Order' 
		BEGIN
			drop table if exists #temp
			select * into #temp from vwopidinventory
			
			SELECT DISTINCT workflowName,intranetTab,ow.OPID,ow.created_On,ow.completed_status,ov.*,t.Color,t.GTIN,t.catalogNo,t.SanMarQty,t.availableQuantity
			,CASE WHEN completed_Status <> 'Success' THEN 'Fail'
				WHEN ow.created_on IS NOT NULL AND completed_On IS NULL THEN 'In Progress' 
				WHEN completed_status = 'success' THEN 'Complete' ELSE '' END AS 'Status'
			FROM vwOPIDCurrWorkflowForTab ow
			LEFT JOIN vwopidviewcurrfortabwithoppo ov on ow.OPID = ov.ID
			LEFT JOIN #temp t on ov.id = t.opid
			WHERE ow.workflowid = @workflowID
			  AND ow.intranetTab = 'Stock Order' 
			  and ow.OPID IS NOT NULL
			ORDER BY ow.OPID DESC
		END
		ELSE IF @tabSelected = 'Digitization' 
		BEGIN
			SELECT DISTINCT workflowName,intranetTab,ow.OPID,ow.created_On,ow.completed_status,ov.*
			,CASE WHEN completed_Status <> 'Success' THEN 'Fail'
				WHEN ow.created_on IS NOT NULL AND completed_On IS NULL THEN 'In Progress' 
				WHEN completed_status = 'success' THEN 'Complete' ELSE '' END AS 'Status'
			FROM vwOPIDCurrWorkflowForTab ow
			LEFT JOIN vwOPIDViewCurrForTabWithOppo ov on ow.OPID = ov.ID
			WHERE ow.workflowid = @workflowID
			  AND ow.intranetTab = @tabSelected
			  and OPID IS NOT NULL
			ORDER BY OPID DESC
		END
		ELSE IF @tabSelected = 'Stock Received' 
		BEGIN
			drop table if exists #temp2
			select * into #temp2 from vwopidinventory

			SELECT DISTINCT workflowName,intranetTab,ow.OPID,ow.created_On,ow.completed_status,ov.*,t.Color,t.GTIN,t.catalogNo,ih.InHouseQty-ih.stockAssigned as 'InHouseQty',ih.stockPending
			,CASE WHEN completed_Status <> 'Success' THEN 'Fail'
				WHEN ow.created_on IS NOT NULL AND completed_On IS NULL THEN 'In Progress' 
				WHEN completed_status = 'success' THEN 'Complete' ELSE '' END AS 'Status'
			FROM vwOPIDCurrWorkflowForTab ow
			LEFT JOIN vwOPIDViewCurrForTabWithOppo ov on ow.OPID = ov.ID
			LEFT JOIN InventoryInHouse ih on ih.opid = ov.ID
			LEFT JOIN #temp2 t on ov.id = t.opid
			WHERE ow.workflowid = @workflowID
			  AND ow.intranetTab = @tabSelected
			  and ow.OPID IS NOT NULL
			ORDER BY OPID DESC
		END
		ELSE IF @tabSelected <> 'Failures' 
		BEGIN
			SELECT DISTINCT workflowName,intranetTab,ow.OPID,ow.created_On,ow.completed_status,ov.*
			,CASE WHEN completed_Status <> 'Success' THEN 'Fail'
				WHEN ow.created_on IS NOT NULL AND completed_On IS NULL THEN 'In Progress' 
				WHEN completed_status = 'success' THEN 'Complete' ELSE '' END AS 'Status'
			FROM vwOPIDCurrWorkflowForTab ow
			LEFT JOIN vwOPIDViewCurrForTab ov on ow.OPID = ov.ID
			WHERE ow.workflowid = @workflowID
			  AND ow.intranetTab = @tabSelected
			  and OPID IS NOT NULL
			ORDER BY OPID DESC
		END
	END
	ELSE
	BEGIN
		SELECT DISTINCT workflowName,intranetTab,processname,ow.OPID,ow.created_On,ow.completed_status,ov.*
			,CASE WHEN completed_Status <> 'Success' THEN 'Fail'
				WHEN ow.created_on IS NOT NULL AND completed_On IS NULL THEN 'In Progress' 
				WHEN completed_status = 'success' THEN 'Complete' ELSE '' END AS 'Status'
		FROM vwOPIDCurrWorkflowALL ow
		LEFT JOIN vwOPIDViewCurrForTab ov on ow.OPID = ov.ID
		WHERE ow.workflowid = @workflowID 
		  and OPID IS NOT NULL
		ORDER BY OPID DESC
	END
END