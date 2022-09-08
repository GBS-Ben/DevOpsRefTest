CREATE PROC [dbo].[usp_popInv] @productID INT
AS 
-------------------------------------------------------------------------------
-- Author Jeremy Fifer
-- Created 03/09/08
-- Purpose    Updates inventory for given productid. Called by: 
					--(1) orderView.asp upon load, against each OPID on page; 
					--(2) order migration; 
					--(3) called from nightly job "usp_popInvNightly"
-------------------------------------------------------------------------------
-- Modification History
--03/09/08		Created, jf
--10/01/18		Cleaned it up, jf.
--07/31/19		Added parentProductID setting to 0 section up top, jf.
--04/27/21		CKB, Markful
-------------------------------------------------------------------------------
/*
CALCULATIONS:   
 This proc uses the following formula to calc inventory:   
 
CURRENT CALC: (REV: 052510)  >>> 
    @stock_Level  =  @inventoryCount + @INV_ADJ - @INV_PS + @INV_WIPHOLD 
	
OLD CALC: (REV: 052510)  >>>    
    @stock_Level  =  @inventoryCount - @INV_WIPHOLD_PHYS + @INV_ADJ - @INV_PS + @INV_WIPHOLD
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
*/ 
SET NOCOUNT ON;
BEGIN TRY
DECLARE @parentProductID INT,
				@stock_Level INT, 
				@inventoryCount INT, 
				@inventoryCountDate DATETIME, 
				@INV_WIPHOLD_PHYS INT, 
				@INV_ADJ INT, 
				@INV_PS INT, 
				@INV_PSCHILD INT, 
				@INV_WIPHOLD INT, 
				@INV_WIPHOLDCHILD INT, 
				@INV_AVAIL INT, 
				@INV_ONHOLD_SOLO INT, 
				@INV_ONHOLD_SOLOCHILD INT, 
				@INV_WIP_SOLO INT 

--///////////////////////////////////////////////////// SECTION A:  set @parentProductID where applicable
SET @parentProductID = (SELECT TOP 1 ISNULL(parentproductID, 0) FROM tblProducts WHERE parentproductID = @productID AND productID <> @productID) 
IF @parentProductID IS NULL
BEGIN
	SET @parentProductID = 0
END

--///////////////////////////////////////////////////// SECTION B:  set @inventoryCount, @inventoryCountDate. There are 2 different sets of calculations based on presense of PPID
IF @parentProductID <> 0 
	BEGIN 
		SET @inventoryCountDate = (SELECT ISNULL(inventoryCountDate, CONVERT(DATETIME, '01/01/1974')) FROM tblProducts WHERE productID = @parentProductID) 

		IF @inventoryCountDate <> CONVERT(DATETIME, '01/01/1974')
		BEGIN 
			SET @inventoryCount = (SELECT ISNULL(inventoryCount, 0) FROM tblProducts WHERE productID = @productID) 
		END 
	END 

IF @parentProductID = 0 
	BEGIN 
		SET @inventoryCountDate = (SELECT ISNULL(inventoryCountDate, CONVERT(DATETIME, '01/01/1974')) FROM tblProducts WHERE productID = @productID) 

		IF @inventoryCountDate <> CONVERT(DATETIME, '01/01/1974')
		BEGIN 
			SET @inventoryCount = (SELECT ISNULL(inventoryCount, 0) FROM tblProducts WHERE productID = @productID) 
		END 
	END 

--///////////////////////////////////////////////////// SECTION C:  set @INV_WIPHOLD values based on presence of PPID
SET @INV_WIPHOLD = (SELECT ISNULL(SUM(a.productQuantity * b.numUnits), 0) 
										FROM tblOrders_Products a 
										INNER JOIN tblProducts b ON a.productID = b.productID 
										LEFT JOIN tblOrders o ON a.orderID = o.orderID
												AND o.orderStatus IN ('Delivered', 'Cancelled', 'Failed', 'On HOM Dock', 'On MRK Dock', 'In Transit', 'In Transit USPS', 'In Transit USPS (Stamped)')
										WHERE b.productID = @productID 
										AND a.deleteX <> 'yes' 
										AND o.orderID IS NULL)

IF @parentProductID <> 0 
	BEGIN 
		SET @INV_WIPHOLDCHILD = (SELECT ISNULL(SUM(a.productQuantity * b.numUnits), 0) 
															FROM tblOrders_Products a 
															INNER JOIN tblProducts b ON a.productID = b.productID 
															LEFT JOIN tblOrders o ON a.orderID = o.orderID
																	AND o.orderStatus IN ('Delivered', 'Cancelled', 'Failed', 'On HOM Dock', 'On MRK Dock', 'In Transit', 'In Transit USPS', 'In Transit USPS (Stamped)')
															WHERE b.productID <> @productID 
															AND b.parentProductID = @productID 
															AND a.deleteX <> 'yes' 
															AND o.orderID IS NULL)

		SET @INV_WIPHOLD = @INV_WIPHOLD + @INV_WIPHOLDCHILD 
	END 

--///////////////////////////////////////////////////// SECTION D:  set @INV_ONHOLD_SOLO INT (as defined by orderStatus LIKE '%waiting%')
SET @INV_ONHOLD_SOLO = (SELECT ISNULL(SUM(a.productQuantity * b.numUnits), 0) 
													FROM tblOrders_Products a 
													INNER JOIN tblProducts b ON a.productID = b.productID 
													INNER JOIN tblOrders o ON a.orderID = o.orderID
													WHERE b.productID = @productID 
													AND a.deleteX <> 'yes' 
													AND o.orderStatus IN ('Waiting For Payment', 'Waiting on Customer', 'Waiting For New Art', 'GTG-Waiting For Payment'))

IF @parentProductID <> 0 
	BEGIN 
		SET @INV_ONHOLD_SOLOCHILD = (SELECT ISNULL(SUM(a.productQuantity * b.numUnits), 0) 
																		FROM tblOrders_Products a 
																		INNER JOIN tblProducts b ON a.productID = b.productID 
																		INNER JOIN tblOrders o ON a.orderID = o.orderID
																		WHERE b.productID <> @productID 
																		AND b.parentProductID = @productID 
																		AND a.deleteX <> 'yes' 
																		AND o.orderStatus IN ('Waiting For Payment', 'Waiting on Customer', 'Waiting For New Art', 'GTG-Waiting For Payment'))

		SET @INV_ONHOLD_SOLO = @INV_ONHOLD_SOLO + @INV_ONHOLD_SOLOCHILD 
	END 
	
--///////////////////////////////////////////////////// SECTION E:  set true WIP values based of preceding calculations ("WIP minus any WIP that are waiting for payment")
SET @INV_WIP_SOLO = @INV_WIPHOLD - @INV_ONHOLD_SOLO

UPDATE tblProducts 
SET INV_ONHOLD_SOLO = @INV_ONHOLD_SOLO, 
	    INV_WIP_SOLO = @INV_WIP_SOLO 
WHERE productID = @productID 

--///////////////////////////////////////////////////// SECTION F:  set @INV_ADJ
IF @parentProductID <> 0 
	BEGIN 
		SET @INV_ADJ = (SELECT SUM(ISNULL(adjustment, 0)) 
										FROM tblInventoryAdjustment 
										WHERE productID = @parentProductID 
										AND adjDate > = @inventoryCountDate) 
	END 

IF @parentProductID = 0 
	BEGIN 
		SET @INV_ADJ = (SELECT SUM(ISNULL(adjustment, 0)) 
										FROM tblInventoryAdjustment 
										WHERE productID = @productID 
										AND adjDate > = @inventoryCountDate) 
	END 

--///////////////////////////////////////////////////// SECTION G:  set @INV_PS
SET @INV_PS = (SELECT ISNULL(SUM(a.productQuantity * b.numUnits), 0)
								FROM tblOrders_Products a
								INNER JOIN tblProducts b ON a.productID = b.productID
								INNER JOIN tblOrders o ON a.orderID = o.orderID
								WHERE b.productID = @productID 
								AND a.deleteX <> 'yes' 
								AND o.orderStatus NOT IN ('failed', 'cancelled')
								AND ISNULL(o.invRefDate, GETDATE()) >= @inventoryCountDate)

IF @parentProductID <> 0 
	BEGIN 
		SET @INV_PSCHILD = (SELECT ISNULL(SUM(a.productQuantity * b.numUnits), 0)
												FROM tblOrders_Products a
												INNER JOIN tblProducts b ON a.productID = b.productID
												INNER JOIN tblOrders o ON a.orderID = o.orderID
												WHERE b.productID <> @productID
												AND b.parentProductID = @productID 
												AND a.deleteX <> 'yes' 
												AND o.orderStatus NOT IN ('failed', 'cancelled')
												AND ISNULL(o.invRefDate, GETDATE()) >= @inventoryCountDate)

		SET @INV_PS = @INV_PS + @INV_PSCHILD 
	END 

--///////////////////////////////////////////////////// SECTION H:  update inventory 
IF @parentProductID <> 0 
	BEGIN 
		UPDATE tblProducts 
		SET INV_ADJ = ISNULL(@INV_ADJ, 0), 
				INV_PS = ISNULL(@INV_PS, 0), 
				INV_WIPHOLD = ISNULL(@INV_WIPHOLD , 0)
		WHERE productID = @parentProductID 
	END 

IF @parentProductID = 0 
	BEGIN 
		UPDATE tblProducts 
		SET INV_ADJ = ISNULL(@INV_ADJ, 0), 
				INV_PS = ISNULL(@INV_PS, 0), 
				INV_WIPHOLD = ISNULL(@INV_WIPHOLD , 0)
		WHERE productID = @productID 
	END 

SET @stock_Level = ISNULL(@inventoryCount,0) + ISNULL(@INV_ADJ,  0) - ISNULL(@INV_PS, 0) + ISNULL(@INV_WIPHOLD, 0)
SET @INV_AVAIL = ISNULL(@stock_Level, 0) - ISNULL(@INV_WIPHOLD, 0)

IF @parentProductID <> 0 
	BEGIN 
		UPDATE tblProducts 
		SET stock_Level = ISNULL(@stock_Level, 0), 
				INV_AVAIL = ISNULL(@INV_AVAIL, 0) 
		WHERE productID = @parentProductID 
	END 

IF @parentProductID = 0 
	BEGIN 
		UPDATE tblProducts 
		SET stock_Level = ISNULL(@stock_Level, 0), 
				INV_AVAIL = ISNULL(@INV_AVAIL, 0) 
		WHERE productID = @productID 
	END 

END TRY
BEGIN CATCH

	--Capture errors if they happen
	EXEC [dbo].[usp_StoredProcedureErrorLog]

END CATCH