CREATE VIEW dbo.vwOPIDPreviousSteps
AS

  SELECT opid,wp.stepNumber,CAST(wp.stepNumber AS VARCHAR(10)) + ' - ' + processName as 'StepDisplay'
  FROM (
	  SELECT opid,runnumber,wp.workflowid,MAX(wp.stepnumber) AS stepNumber
	  FROM tblopidproductionprocess opp
	  LEFT JOIN gbsController_vwworkflowprocess wp ON opp.wpid = wp.wpid
	  WHERE opp.runnumber = (SELECT MAX(runnumber) FROM tblopidproductionprocess opp2 WHERE opp.opid = opp2.opid)
	  GROUP BY opid,runnumber,wp.workflowid
	  ) a
  INNER JOIN gbsController_vwworkflowprocess wp ON a.stepnumber >= wp.stepnumber AND a.workflowid = wp.workflowid