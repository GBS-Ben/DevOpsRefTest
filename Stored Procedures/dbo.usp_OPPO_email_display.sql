CREATE PROC usp_OPPO_email_display @OPID INT = 0
AS
-------------------------------------------------------------------------------
-- Author      Jeremy Fifer
-- Created     07/27/18
-- Purpose    Used to display the OPID email on orderView.asp on the Intranet.
-------------------------------------------------------------------------------
-- Modification History
--
-- 07/27/18	Created, jf.
-------------------------------------------------------------------------------
SELECT email
FROM tblOPPO_email 
WHERE OPID = @OPID