
CREATE PROC InsertOPIDLOG
@OPID INT,
@LOGEVENT VARCHAR(255)
AS
/*-------------------------------------------------------------------------------
Author		Jeremy Fifer
Created		08/07/2020
Purpose		Inserts OPID logging events for entity status tracking.
-------------------------------------------------------------------------------
Modification History

08/07/2020		Created, jf
-------------------------------------------------------------------------------
*/
INSERT INTO OPIDLOG (OPID, LOGEVENT) 
SELECT @OPID, @LOGEVENT