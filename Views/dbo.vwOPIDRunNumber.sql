
CREATE VIEW [dbo].[vwOPIDRunNumber]
AS
SELECT  OPID,RunNumber,isActive,max(wp.StepNumber) as stepNumber
FROM tblOPIDProductionProcess opp
LEFT JOIN gbsController_vwWorkflowProcess wp on opp.workflowID = wp.workflowID and opp.wpid = wp.wpid
WHERE RunNumber = (SELECT MAX(RunNumber) as RunNumber FROM tblOPIDProductionProcess opp2 WHERE opp.OPID = opp2.OPID)
GROUP BY OPID,RunNumber,isActive