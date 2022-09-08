





CREATE VIEW [dbo].[vwOPIDCurrWorkflowAll]
AS
-- all workflow steps and unfinished OPIDs on that step
SELECT p.workflowid,p.workflowName,p.intranetTab,p.processName,p.wpid,opp.opid,opp.completed_Status,opp.created_On,opp.completed_On,opp.isActive,RANK() OVER(PARTITION BY p.workflowid ORDER BY MIN(stepnumber)) AS 'processSort'
FROM dbo.gbsController_vwWorkflowProcess p
LEFT JOIN (SELECT DISTINCT wp.workflowid,wp.intranetTab,opp.opid,opp.completed_Status,opp.created_On,opp.completed_On,opp.isActive,wp.processName
			FROM tblopidproductionprocess opp
			INNER JOIN dbo.gbsController_vwWorkflowProcess  wp ON opp.wpid = wp.wpid and opp.workflowid = wp.workflowid
			WHERE completed_On IS NULL AND  isActive = 1) opp ON isnull(opp.intranetTab,opp.processName) = isnull(p.intranetTab,p.processName) and opp.workflowid = p.workflowid
GROUP BY p.workflowid,p.workflowName,p.intranetTab,p.processName,p.wpid,opp.opid,opp.completed_Status,opp.created_On,opp.completed_On,opp.isActive;