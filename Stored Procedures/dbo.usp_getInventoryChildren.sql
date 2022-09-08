/*
    Steve Palmer
    Feb 26, 2015
    Gets the main top product entry for the Inventory Page
    Example Calls:
      EXEC usp_getInventory 87;
      EXEC usp_getInventory 155;
      EXEC usp_getInventory 265;
      EXEC usp_getInventory 190097;
      EXEC usp_getInventory 190297;
*/
CREATE PROCEDURE [dbo].[usp_getInventoryChildren]
  @parentProductID AS INT
  , @From AS DATETIME
  , @To AS DATETIME
AS 
BEGIN
  SELECT p.productID
    , p.productCode
    , p.parentProductID
    , p.productName
    , p.INV_WIPHOLD
    , p.INV_AVAIL AS AvailStock
    , p.productType
    , p.onOrder
    , p.INV_ONHOLD_SOLO AS OnHold
    , 0 AS OnHoldTots
    , p.INV_WIP_SOLO AS WIP
    , p.stock_Level AS PhysStock
    , p.numUnits
    , dbo.fnTotalValueSoldChildInPeriod(p.productID, @From, @To) AS totalValueSold
    , dbo.fnTotalNumberSoldChildInPeriod(p.productID, @From, @To) AS totalNumberSold
    , (dbo.fnTotalNumberSoldChildInPeriod(p.productID, @From, @To))  AS totalNumberSoldTot
    , dbo.fnNbrTrans(p.productID, @From, @To) AS NumTrans
  FROM tblProducts p 
 WHERE p.parentProductID = @parentProductID  

  ORDER BY p.productID;
END