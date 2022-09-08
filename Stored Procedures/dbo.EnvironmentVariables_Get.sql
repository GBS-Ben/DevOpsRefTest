-- =============================================
-- Author:		CBrowne
-- Create date: 04/12/21
-- Description:	lookup variablevalue from EnvironmentVariables table
-- =============================================
CREATE PROCEDURE [dbo].[EnvironmentVariables_Get]
	@VariableName VARCHAR(255),
	@VariableValue varchar(255) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	 SELECT @VariableValue = VariableValue FROM EnvironmentVariables WHERE VariableName = @VariableName

END