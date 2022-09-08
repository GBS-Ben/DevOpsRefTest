CREATE PROCEDURE [dbo].[usp_StoredProcedureErrorLog]
AS
BEGIN
SET NOCOUNT ON 
        
         INSERT INTO [dbo].[StoredProcedureErrorLog]  
             (
             ErrorNumber 
            ,ErrorDescription 
            ,ErrorProcedure 
            ,ErrorState 
            ,ErrorSeverity 
            ,ErrorLine 
            ,ErrorTime 
           )
           VALUES
           (
             ERROR_NUMBER()
            ,ERROR_MESSAGE()
            ,ERROR_PROCEDURE()
            ,ERROR_STATE()
            ,ERROR_SEVERITY()
            ,ERROR_LINE()
            ,GETDATE()  
           );
    
SET NOCOUNT OFF    
END