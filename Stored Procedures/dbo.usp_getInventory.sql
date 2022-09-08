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
CREATE PROCEDURE [dbo].[usp_getInventory]
  @ProductID AS INT
AS 
BEGIN
  SELECT productID
    , p.productCode
    , p.parentProductID
    , p.productName
    , p.INV_WIPHOLD
    , p.INV_AVAIL
    , p.productType
    , p.onOrder
    , p.INV_ONHOLD_SOLO
    , p.INV_WIP_SOLO AS WIP
    , p.stock_Level AS 'Phys. Stock'
    , dbo.fnTotalValueSold(@ProductID) AS fn_soldvalue
    , dbo.fnTotalNumberSold(@ProductID) AS fn_soldnumber
  FROM tblProducts p 
  WHERE p.productID = @ProductID;
END