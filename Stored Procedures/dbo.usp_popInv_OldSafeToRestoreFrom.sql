CREATE PROC [dbo].[usp_popInv_OldSafeToRestoreFrom] @productID VARCHAR(255) 
AS 
    /* 
    ____________________________________________________________ 
     
    CREATED BY: JF 
    CREATED DATE:  03/09/09 
    LAST UPDATE DATE:  05/25/10 
    LAST UPDATE:  Removed @INV_WIPHOLD_PHYS concept / main changes to Sections B & G. 
    --04/27/21		CKB, Markful
____________________________________________________________ 
     
    USAGE:   
     
    This proc updates Inventory for a given product when: 
      1.  A manual inventory is run 
      2.  A product is adjusted in the Inventory Intranet Page 
      3.  Each time usp_manualINV runs 
     
    This product update Inventory for ALL products in tblProducts when: 
      1.  Each time ACTMIG Runs  
      2.  Each time MIG1 Runs (as of 3/9/9 MIG1 is NOT firing it, but that may change. Discuss)
    ____________________________________________________________ 
     
    CALCULATIONS:   
     
    This proc uses the following formula to calc INV: 
     
      OLD CALC: (REV: 052510)  >>>    
              @stock_Level  =  @inventoryCount - @INV_WIPHOLD_PHYS + @INV_ADJ - @INV_PS + @INV_WIPHOLD
     
     
      CURRENT CALC: (REV: 052510)  >>> 
               @stock_Level  =  @inventoryCount + @INV_ADJ - @INV_PS + @INV_WIPHOLD 
    ____________________________________________________________ 
     
    VARAIBLE DEFINITIONS: 
     
    @productID  =  ProductID submitted. 
    @parentProductID  =  parentProductID for @productID. 
    @stock_Level  =  The current physical stock level of @productID. 
    @inventoryCount  =  The last manual inventory count taken of @productID.  Value = NULL unless a physical inventory has been taken.
    @inventoryCountDate  =  Timestamp at which the last manual inventory count was taken for @productID.  Value = '1974-01-01 00:00:00.000' unless a physical inventory has been taken. 
    @INV_ADJ  =  Adjustments to inventory for @productID.  If @inventoryCount<>NULL, then equal to adjustments made to inventory for @productID since @inventoryCountDate.
    @INV_PS  =  Products sold for @productID.  If @inventoryCount<>NULL, then equal to products sold for @productID since @inventoryCountDate.
    @INV_PSCHILD  =  Temp variable used to calculate @INV_PS. 
    @INV_WIPHOLD  =  The number of units for @productID either in WIP or ON HOLD.  This value is calculated and used, regardless of @inventoryCount's value.
    @INV_WIPHOLDCHILD  =  Temp variable used to calculate @INV_WIPHOLD. 
    @INV_AVAIL  =  @stock_Level - @INV_WIPHOLD 
    @INV_ONHOLD_SOLO =  The number of units for @productID only "ON HOLD". 
    @INV_ONHOLD_SOLOCHILD =  Temp variable used to calculate @INV_ONHOLD_SOLO. 
    @INV_WIP_SOLO = @INV_WIPHOLD - @INV_ONHOLD_SOLO 
    @INVREFDATE  =  tblOrders.invRefDate 
    ____________________________________________________________ 
    exec usp_popInvNew '6722' 
    select * from tblProducts where productID = 6722 
    */ 
	SET NOCOUNT ON;

	BEGIN TRY


		DECLARE @parentProductID      VARCHAR(255), 
				@stock_Level          INT, 
				@inventoryCount       INT, 
				@inventoryCountDate   DATETIME, 
				@INV_WIPHOLD_PHYS     INT, 
				@INV_ADJ              INT, 
				@INV_PS               INT, 
				@INV_PSCHILD          INT, 
				@INV_WIPHOLD          INT, 
				@INV_WIPHOLDCHILD     INT, 
				@INV_AVAIL            INT, 
				@INV_ONHOLD_SOLO      INT, 
				@INV_ONHOLD_SOLOCHILD INT, 
				@INV_WIP_SOLO         INT 

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--SECTION A:  SET @parentProductID 
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--This step makes sure that we ONLY set @parentProductID to a value IF there is a parent/child relationship between @productID and some other product.  We will set it to '0' if this is not the case.
		SET @parentProductID = (SELECT TOP 1 parentproductID 
								FROM tblProducts 
								WHERE parentproductID = @productID 
								   AND productID <> @productID) 

		IF @parentProductID IS NULL OR @parentProductID = ''
		  BEGIN 
			  SET @parentProductID = '0' 
		  END 

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--SECTION B:  SET @inventoryCount, @inventoryCountDate
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- STEP B1: if parentProductID IS available 
		IF @parentProductID <> 0 
		  BEGIN 
			  SET @inventoryCountDate = (SELECT inventoryCountDate 
										 FROM tblProducts 
										 WHERE productID = @parentProductID) 

			  IF @inventoryCountDate IS NULL OR @inventoryCountDate = ''
				BEGIN 
					SET @inventoryCountDate = CONVERT(DATETIME, '01/01/1974') 
				END 

			  IF @inventoryCountDate <> 0 
				BEGIN 
					SET @inventoryCount = (SELECT inventoryCount 
										   FROM tblProducts 
										   WHERE productID = @productID) 

					IF @inventoryCount IS NULL OR @inventoryCount = ''
					  BEGIN 
						  SET @inventoryCount = 0 
					  END 
				END 
		  END 

		-- STEP B2:  if parentProductID IS NOT available 
		IF @parentProductID = 0 
		  BEGIN 
			  SET @inventoryCountDate = (SELECT inventoryCountDate 
										 FROM tblProducts 
										 WHERE productID = @productID) 

			  IF @inventoryCountDate IS NULL OR @inventoryCountDate = ''
				BEGIN 
					SET @inventoryCountDate = CONVERT(DATETIME, '01/01/1974') 
				END 

			  IF @inventoryCountDate <> 0 
				BEGIN 
					SET @inventoryCount = (SELECT inventoryCount 
										   FROM tblProducts 
										   WHERE productID = @productID) 

					IF @inventoryCount IS NULL OR @inventoryCount = ''
					  BEGIN 
						  SET @inventoryCount = 0 
					  END 
				END 
		  END 

		-- STEP B3:  if conditions were not met above, confirm deNULL of 3 variables in this section. 
		IF @inventoryCountDate IS NULL OR @inventoryCountDate = ''
		  BEGIN 
			  SET @inventoryCountDate = CONVERT(DATETIME, '01/01/1974') 
		  END 

		IF @inventoryCount IS NULL OR @inventoryCount = ''
		  BEGIN 
			  SET @inventoryCount = 0 
		  END 

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--SECTION C:  SET @INV_WIPHOLD 
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- STEP C1: if parentProductID IS available 
		IF @parentProductID <> 0 
		  BEGIN 
			  SET @INV_WIPHOLD = (SELECT SUM(a.productQuantity * b.numUnits) 
								  FROM tblOrders_Products a 
								  JOIN tblProducts b 
										ON a.productID = b.productID 
								  WHERE b.productID = @productID 
								  AND a.deleteX <> 'yes' 
								  AND orderID NOT IN 
										(SELECT orderID 
										FROM tblOrders 
										WHERE orderStatus = 'Delivered' 
										OR orderStatus LIKE '%transit%' 
										OR orderStatus = 'On HOM Dock'
										OR orderStatus = 'On MRK Dock'
										OR orderStatus = 'cancelled' 
										OR orderStatus = 'failed')) 

			  IF @INV_WIPHOLD IS NULL OR @INV_WIPHOLD = ''
				BEGIN 
					SET @INV_WIPHOLD = '0' 
				END 

			  SET @INV_WIPHOLDCHILD = (SELECT SUM(a.productQuantity * b.numUnits) 
									   FROM tblOrders_Products a 
									   JOIN tblProducts b 
												ON a.productID = b.productID 
									   WHERE b.productID <> @productID 
									   AND b.parentProductID = @productID 
									   AND a.deleteX <> 'yes' 
									   AND orderID NOT IN 
											(SELECT orderID 
											FROM tblOrders 
											WHERE orderStatus = 'Delivered' 
											OR orderStatus LIKE '%transit%' 
											OR orderStatus = 'On HOM Dock'
											OR orderStatus = 'On MRK Dock'
											OR orderStatus = 'cancelled' 
											OR orderStatus = 'failed')) 

			  IF @INV_WIPHOLDCHILD IS NULL OR @INV_WIPHOLDCHILD = ''
				BEGIN 
					SET @INV_WIPHOLDCHILD = '0' 
				END 

			  SET @INV_WIPHOLD = @INV_WIPHOLD + @INV_WIPHOLDCHILD 
		  END 

		-- STEP C2: if parentProductID IS NOT available 
		IF @parentProductID = 0 
		  BEGIN 
			  SET @INV_WIPHOLD = (SELECT SUM(a.productQuantity * b.numUnits) 
								  FROM tblOrders_Products a 
										 JOIN tblProducts b 
										   ON a.productID = b.productID 
								  WHERE b.productID = @productID 
								  AND a.deleteX <> 'yes' 
								  AND orderID NOT IN 
											(SELECT orderID 
											FROM tblOrders 
											WHERE orderStatus = 'Delivered' 
											OR orderStatus LIKE '%transit%' 
											OR orderStatus = 'On HOM Dock'
											OR orderStatus = 'On MRK Dock'
											OR orderStatus = 'cancelled' 
											OR orderStatus = 'failed')) 

			  IF @INV_WIPHOLD IS NULL OR @INV_WIPHOLD = ''
				BEGIN 
					SET @INV_WIPHOLD = '0' 
				END 
		  END

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--SECTION D:  SET @INV_ONHOLD_SOLO INT (as defined by orderStatus LIKE '%waiting%')
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- STEP D1: if parentProductID IS available 
		IF @parentProductID <> 0 
		  BEGIN 
			  SET @INV_ONHOLD_SOLO = (SELECT SUM(a.productQuantity * b.numUnits) 
									  FROM tblOrders_Products a 
									  JOIN tblProducts b 
											ON a.productID = b.productID 
									  WHERE b.productID = @productID 
									  AND a.deleteX <> 'yes' 
									  AND orderID IN 
											(SELECT orderID 
											FROM tblOrders 
											WHERE orderStatus LIKE 'waiting%')) 

			  IF @INV_ONHOLD_SOLO IS NULL OR @INV_ONHOLD_SOLO = ''
				BEGIN 
					SET @INV_ONHOLD_SOLO = '0' 
				END 

			  SET @INV_ONHOLD_SOLOCHILD = (SELECT SUM(a.productQuantity * b.numUnits) 
										   FROM tblOrders_Products a 
										   JOIN tblProducts b 
												ON a.productID = b.productID 
										   WHERE b.productID <> @productID 
										   AND b.parentProductID = @productID 
										   AND a.deleteX <> 'yes' 
										   AND orderID IN 
												(SELECT orderID 
												FROM tblOrders 
												WHERE orderStatus LIKE 'waiting%')) 

			  IF @INV_ONHOLD_SOLOCHILD IS NULL 
				BEGIN 
					SET @INV_ONHOLD_SOLOCHILD = '0' 
				END 

			  SET @INV_ONHOLD_SOLO = @INV_ONHOLD_SOLO + @INV_ONHOLD_SOLOCHILD 
		  END 

		-- STEP D2: if parentProductID IS NOT available  
		IF @parentProductID = 0 
		  BEGIN 
			  SET @INV_ONHOLD_SOLO = (SELECT SUM(a.productQuantity * b.numUnits) 
									  FROM tblOrders_Products a 
									  JOIN tblProducts b 
											ON a.productID = b.productID 
									  WHERE b.productID = @productID 
										 AND a.deleteX <> 'yes' 
										 AND orderID IN 
											(SELECT orderID 
											FROM tblOrders 
											WHERE orderStatus LIKE 'waiting%')) 

			  IF @INV_ONHOLD_SOLO IS NULL OR @INV_ONHOLD_SOLO = ''
				BEGIN 
					SET @INV_ONHOLD_SOLO = '0' 
				END 
		  END 

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--SECTION E:  SET @INV_ONHOLD_SOLO INT // UPDATE TBLPRODUCTS 
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- STEP E1: if parentProductID IS available 
		SET @INV_WIP_SOLO = @INV_WIPHOLD - @INV_ONHOLD_SOLO --// which basically means, "WIP minus any WIP that are waiting for payment"

		UPDATE tblProducts 
		SET    INV_ONHOLD_SOLO = @INV_ONHOLD_SOLO, 
			   INV_WIP_SOLO = @INV_WIP_SOLO 
		WHERE productID = @productID 

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--SECTION F:  SET @INV_ADJ 
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-- STEP F0: UPDATE the referenced table to remove NULL from math

		UPDATE tblInventoryAdjustment 
		SET adjustment = 0
		WHERE adjustment IS NULL
		AND productID = @productID

			-- STEP F1: if parentProductID IS available 
		IF @parentProductID <> 0 
		  BEGIN 
			  SET @INV_ADJ = (SELECT SUM(adjustment) 
							  FROM tblInventoryAdjustment 
							  WHERE productID = @parentProductID 
							  AND adjDate > = @inventoryCountDate) 
		  END 

		-- STEP F2: if parentProductID IS NOT available 
		IF @parentProductID = 0 
		  BEGIN 
			  SET @INV_ADJ = (SELECT SUM(adjustment) 
							  FROM tblInventoryAdjustment 
							  WHERE productID = @productID 
							  AND adjDate > = @inventoryCountDate) 
		  END 

		IF @INV_ADJ IS NULL OR @INV_ADJ = ''
		  BEGIN 
			  SET @INV_ADJ = '0' 
		  END 

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--SECTION G:  SET @INV_PS 
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--STEP G1:  if parentProductID IS available 
		IF @parentProductID <> 0 
		  BEGIN 
			  SET @INV_PS = (SELECT SUM(a.productQuantity * b.numUnits) --// this line was missing "* b.numUnits"; fixed on 11/24/15; JF
							 FROM tblOrders_Products a
							 JOIN tblProducts b 
									 ON a.productID = b.productID 
							 WHERE b.productID = @productID 
							 AND a.deleteX <> 'yes' 
							 AND a.orderID IN 
								(SELECT orderID 
								 FROM tblOrders 
								 WHERE orderStatus <> 'cancelled' 
								 AND orderStatus <> 'failed' 
								 AND invRefDate > = @inventoryCountDate 
								 AND invRefDate IS NOT NULL)) 

			  IF @INV_PS IS NULL OR @INV_PS = ''
				BEGIN 
					SET @INV_PS = '0' 
				END 

			  SET @INV_PSCHILD = (SELECT SUM(a.productQuantity * b.numUnits)
								  FROM tblOrders_Products a 
								  JOIN tblProducts b 
										   ON a.productID = b.productID 
								  WHERE b.productID <> @productID 
									 AND b.parentProductID = @productID 
									 AND a.deleteX <> 'yes' 
									 AND a.orderID IN 
										(SELECT orderID 
										FROM tblOrders 
										WHERE orderStatus <> 'cancelled' 
										AND orderStatus <> 'failed' 
										AND invRefDate > = @inventoryCountDate 
										AND invRefDate IS NOT NULL)) 

			  IF @INV_PSCHILD IS NULL OR @INV_PSCHILD = ''
				BEGIN 
					SET @INV_PSCHILD = '0' 
				END 

			  SET @INV_PS = @INV_PS + @INV_PSCHILD 
		  END 

		--STEP G2:  if parentProductID IS NOT available 
		IF @parentProductID = 0 
		  BEGIN 
			  SET @INV_PS = (SELECT SUM(a.productQuantity * b.numUnits) --// this line was missing "* b.numUnits"; fixed on 11/24/15; JF
							 FROM tblOrders_Products a
							 JOIN tblProducts b 
									 ON a.productID = b.productID 
							 WHERE b.productID = @productID 
								AND a.deleteX <> 'yes' 
								AND a.orderID IN 
										(SELECT orderID 
										FROM tblOrders 
										WHERE orderStatus <> 'cancelled' 
										AND orderStatus <> 'failed' 
										AND invRefDate > = @inventoryCountDate 
										AND invRefDate IS NOT NULL)) 

			  IF @INV_PS IS NULL OR @INV_PS = ''
				BEGIN 
					SET @INV_PS = '0' 
				END 
		  END 

		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--SECTION H:  UPDATE INVENTORY FIELDS 
		--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		--STEP H1:  if parentProductID IS available 
		IF @parentProductID <> 0 
		  BEGIN 
			  UPDATE tblProducts 
			  SET    INV_ADJ = @INV_ADJ, 
					 INV_PS = @INV_PS, 
					 INV_WIPHOLD = @INV_WIPHOLD 
			  WHERE productID = @parentProductID 
		  END 

		--STEP H2:  if parentProductID IS NOT available 
		IF @parentProductID = 0 
		  BEGIN 
			  UPDATE tblProducts 
			  SET    INV_ADJ = @INV_ADJ, 
					 INV_PS = @INV_PS, 
					 INV_WIPHOLD = @INV_WIPHOLD 
			  WHERE productID = @productID 
		  END 

		--STEP H3:  calculate physical stock inventory: @stock_Level (Formula: See notes @ top of proc)
				--  in english: "Take the manual inventory count, if any; add to that all adjustments, whether they add up to a positive or a negative value; subtract all products sold; and lastly, add
				--  back into the stock_level, any products in WIP on orders that are waiting for payment. This final value is your current Stock Level.
		SET @stock_Level = @inventoryCount + @INV_ADJ - @INV_PS + @INV_WIPHOLD 

		IF @stock_Level IS NULL OR @stock_Level = ''
		  BEGIN 
			  SET @stock_Level = '0' 
		  END 

		--STEP H4:  calculate available stock inventory: @INV_AVAIL (Formula: @INV_AVAIL = @stock_Level - @INV_WIPHOLD)
				--  in english: this value  is the Stock Level described above, with any products in WIP subtracted from that Stock Level. This is your actual Inventory Available.
		SET @INV_AVAIL = @stock_Level - @INV_WIPHOLD 

		IF @INV_AVAIL IS NULL OR @INV_AVAIL = ''
		  BEGIN 
			  SET @INV_AVAIL = '0'
		  END 

		--STEP H5: if parentProductID IS available, set table values for stock_Level, INV_AVAIL 
		IF @parentProductID <> 0 
		  BEGIN 
			  UPDATE tblProducts 
			  SET    stock_Level = @stock_Level, 
					 INV_AVAIL = @INV_AVAIL 
			  WHERE productID = @parentProductID 
		  END 

		--STEP H6: if parentProductID IS NOT available, set table values for stock_Level, INV_AVAIL 
		IF @parentProductID = 0 
		  BEGIN 
			  UPDATE tblProducts 
			  SET    stock_Level = @stock_Level, 
					 INV_AVAIL = @INV_AVAIL 
			  WHERE productID = @productID 
		  END 


END TRY
BEGIN CATCH

	  --Capture errors if they happen
	  EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH