CREATE PROCEDURE [dbo].[usp_teamProducts]
  @From AS DATETIME,
  @To AS DATETIME
AS 
BEGIN

    SELECT 
      ut.TeamName
    , op.productID
    , op.productCode
    , p.productName
    , SUBSTRING(cs.shipping_PostCode,1,3) AS Zip
    , cs.shipping_State
    , SUM(op.productQuantity) AS 'Quantity'
    , SUM(o.orderTotal) AS 'Order Total'
    , COUNT(*) AS 'Count'
    From tblOrders o
    INNER JOIN tblOrders_Products op ON
      op.orderID = o.orderID
    INNER JOIN usp_tblTeamProducts utp ON
      utp.ProductID = op.productID
    INNER JOIN usp_tblTeams ut ON 
      ut.ID = utp.TeamID
    INNER JOIN tblProducts p ON
      p.productID = op.productID
    INNER JOIN tblCustomers c ON 
      c.customerID = o.customerID
    INNER JOIN tblCustomers_ShippingAddress cs ON
      cs.orderNo = o.orderNo
    WHERE  (o.orderstatus <> 'Cancelled' AND o.orderStatus <> 'Failed'
         AND op.deletex <> 'yes'
         AND o.orderDate BETWEEN @From AND @To)
    
    GROUP BY 
      ut.TeamName
      , op.productID
      , op.productCode
      , p.productName
      , SUBSTRING(cs.shipping_PostCode,1,3)
      , cs.shipping_State
    
END