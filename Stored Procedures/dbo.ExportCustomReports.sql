-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[ExportCustomReports]
	@Include bit,
	@From nvarchar(25),
	@To nvarchar(25),	
	@SqlWhere nvarchar(1024)
	
AS
BEGIN
	
	SET NOCOUNT ON;
	--DECLARE @CurrentView nvarchar(50)='CustomReportsView';
	DECLARE @SQLStatement nvarchar(4000);
	DECLARE @SQLStatementCount nvarchar(3000);
		IF(@SqlWhere LIKE '%productName%' or @SqlWhere LIKE '%productCode%')begin	
		select @Include= 1;
		end;
	IF (@Include= 0)
	begin			
	set @SQLStatement = 
	' SELECT DISTINCT
	      o.orderNo,
	      o.orderStatus,
	      o.orderType,
	      o.orderDate,
	      o.orderTotal,
	      o.customerName,
	      o.customerID,
	      o.company,
	      o.email,
	      o.displayPaymentStatus,
	      o.Shipping_State,
	      o.Shipping_PostCode,
	      o.orderID,
	      '''' as productCode ,	      
	      '''' as productName,
	      0.0 as productPrice,
	      0 as productQuantity,
	      o.street,
	      o.street2,
	      o.suburb,
	      o.state,
	      o.postCode,
	      o.ShippingName,
	      o.Shipping_Company,
	      o.Shipping_Street,
	      o.Shipping_Street2,
	      o.Shipping_Suburb  ,
	      o.phone  
	  FROM CustomReportsExportView as o WHERE ( o.orderDate >= '''+@From+''' AND o.orderDate < '''+@To+''') '+@SqlWhere+''; 
	 	end;
	 	 else
	   if  (@Include = 1)   
	   begin  
	 	 set @SQLStatement = 
	' SELECT DISTINCT
	      o.orderNo,
	      o.orderStatus,
	      o.orderType,
	      o.orderDate,
	      o.orderTotal,
	      o.customerName,
	      o.customerID,
	      o.company,
	      o.email,
	      o.displayPaymentStatus,
	      o.Shipping_State,
	      o.Shipping_PostCode,
	      o.orderID,
	      o.productCode,
	      o.productName,
	      o. productPrice,
	      o.productQuantity,
	      o.street,
	      o.street2,
	      o.suburb,
	      o.state,
	      o.postCode,
	      o.ShippingName,
	      o.Shipping_Company,
	      o.Shipping_Street,
	      o.Shipping_Street2,
	      o.Shipping_Suburb ,
	      o.phone    
	  FROM CustomReportsWithProductView as o WHERE ( o.orderDate >= '''+@From+''' AND o.orderDate < '''+@To+''') '+@SqlWhere+''; 
	  end;
	 	 EXEC( @SQLStatement);	  
	   END