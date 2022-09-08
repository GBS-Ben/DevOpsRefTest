SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO








CREATE PROC [dbo].[usp_ProductionTime] 
	@SignTimeNew int = 99, 
	@ApparelTimeNew int = 99, 
	@AwardTimeNew int = 99, 
	@NBTimeNew int = 99,
	@BCTimeNew int = 99,
	@BBTimeNew int = 99,
	@FBTimeNew int = 99,
	@CALTimeNew int = 99
AS
SET NOCOUNT ON;
/*
-------------------------------------------------------------------------------
Author      Jonathan SB
Created     06/13/2022
Purpose     Track Production Time by Department
-------------------------------------------------------------------------------
Modification History

 06/13/22		Created; JSB.
 06/14/22       Added BB, FB, and CAL; JSB
-------------------------------------------------------------------------------
Example:

	EXEC [usp_productionTime] 1,2,0,2,3,5,6,2

*/


BEGIN TRY
		
		DECLARE
		@SignTimeOld int,
		@ApparelTimeOld int, 
		@AwardTimeOld int, 
		@NBTimeOld int,
		@BCTimeOld int,
		@BBTimeOld int,
		@FBTimeOld int,
		@CALTimeOld int

	SELECT TOP 1 @SignTimeOld = SignTime, @ApparelTimeOld = ApparelTime, @AwardTimeOld = AwardsTime, @NBTimeOld= NBTime, @BCTimeOld= BCTime, 
	@BBTimeOld = BBTime, @FBTimeOld = FBTime, @CALTimeOld = CALTime FROM tblProduction_Time ORDER BY PKID DESC

	
	INSERT INTO tblProduction_Time(SignTime, ApparelTime, AwardsTime, NBTime, BCTime, BBTime, FBTime, CALTime, entryDate)
	VALUES (CASE WHEN @SignTimeNew = 99 THEN @SignTimeOld ELSE @SignTimeNew END,
	CASE WHEN @ApparelTimeNew = 99 THEN @ApparelTimeOld ELSE @ApparelTimeNew END,
	CASE WHEN @AwardTimeNew = 99 THEN @AwardTimeOld ELSE @AwardTimeNew END,
	CASE WHEN @NBTimeNew = 99 THEN @NBTimeOld ELSE @NBTimeNew END,
	CASE WHEN @BCTimeNew = 99  THEN @BCTimeOld ELSE @BCTimeNew END,
	CASE WHEN @BBTimeNew = 99  THEN @BBTimeOld ELSE @BBTimeNew END,
	CASE WHEN @FBTimeNew = 99  THEN @FBTimeOld ELSE @FBTimeNew END,
	CASE WHEN @CALTimeNew = 99  THEN @CALTimeOld ELSE @CALTimeNew END,
	GETDATE())

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH
GO
