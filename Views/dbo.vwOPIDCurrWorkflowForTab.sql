








CREATE VIEW [dbo].[vwOPIDCurrWorkflowForTab]
AS
-- workflow steps that are assigned intranet tab and unfinished OPIDs on that step
SELECT p.workflowid,p.workflowName,p.intranetTab,p.wpid,opp.opid,opp.completed_Status,opp.created_On,opp.completed_On,RANK() OVER(PARTITION BY p.workflowid ORDER BY MIN(stepnumber)) AS 'processSort'
FROM dbo.gbsController_vwWorkflowProcess p
LEFT JOIN (SELECT DISTINCT wp.workflowid,wp.intranetTab,opp.opid,opp.completed_Status,opp.created_On,opp.completed_On
			FROM tblopidproductionprocess opp
			INNER JOIN dbo.gbsController_vwWorkflowProcess  wp ON opp.wpid = wp.wpid and opp.workflowid = wp.workflowid
			WHERE completed_On IS NULL AND  isActive = 1) opp ON opp.intranetTab = p.intranetTab and opp.workflowid = p.workflowid
WHERE p.intranetTab IS NOT NULL
GROUP BY p.workflowid,p.workflowName,p.intranetTab,p.wpid,opp.opid,opp.completed_Status,opp.created_On,opp.completed_On;