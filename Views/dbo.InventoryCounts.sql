






--drop view [InventoryOrders]
CREATE VIEW [dbo].[InventoryCounts] --select * from [InventoryCounts]
AS
	select inv.skupattern, AvailableQuantity=SUM(AvailableQuantity), ProductThreshold=invs.Threshold, inv.IsActive, PendingQuantity=SUM(PendingQuantity)
		FROM (
			--INVENTORY
			select inv.skupattern, IsActive, AvailableQuantity=isnull(sum(inv.quantity-inv.Threshold),0),cast(0 as INT) as PendingQuantity
			--select *
			from nopcommerce_tblProducts_Inventory inv
			group by inv.SkuPattern, IsActive
			union 
			--ORDERS PENDING to remove from avail count
			select  ProductCode=STUFF(STUFF(LEFT(ProductCode, 10), 3, 2, '__'), 9,1
					  , CASE textValue
						WHEN 'XS' THEN 'T'
						WHEN 'small' THEN 'S'
						WHEN 'medium' THEN 'M'
						WHEN 'large' THEN 'L'
						WHEN 'XL' THEN 'X'
						WHEN '2XL' THEN '2'
						WHEN '3XL' THEN '3'
						WHEN '4XL' THEN '4'
						WHEN '5XL' THEN '5'
						WHEN '' THEN '0'
						END )
				, IsActive=1--hardcode for orders
				, TotalOrderCount=sum(NewOrders) * -1--negate these so they are removed
				, PendingOrderCount=sum(PendingOrders) 
			--SELECT * 
			from dbo.InventoryOrders
			GROUP BY STUFF(STUFF(LEFT(ProductCode, 10), 3, 2, '__'), 9,1
					  , CASE textValue
						WHEN 'XS' THEN 'T'
						WHEN 'small' THEN 'S'
						WHEN 'medium' THEN 'M'
						WHEN 'large' THEN 'L'
						WHEN 'XL' THEN 'X'
						WHEN '2XL' THEN '2'
						WHEN '3XL' THEN '3'
						WHEN '4XL' THEN '4'
						WHEN '5XL' THEN '5'
						WHEN '' THEN '0'
						END )
			) inv
		inner join nopcommerce_tblProducts_InventorySettings invs on invs.SkuPattern=inv.SkuPattern
		GROUP BY inv.skupattern, invs.Threshold, inv.IsActive