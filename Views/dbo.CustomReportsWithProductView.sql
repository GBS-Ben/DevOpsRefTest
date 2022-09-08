﻿


CREATE VIEW [dbo].[CustomReportsWithProductView]
AS
SELECT DISTINCT 
                      TOP (100) PERCENT 
							 dbo.tblOrders.orderNo, dbo.tblOrders.orderStatus, dbo.tblOrders.orderType, dbo.tblOrders.orderTotal, 
                      dbo.tblCustomers.firstName + '  ' + dbo.tblCustomers.surname AS customerName, dbo.tblOrders.customerID, dbo.tblCustomers.company, dbo.tblCustomers.email, 
                      dbo.tblOrders.displayPaymentStatus, dbo.tblOrders.orderID, dbo.tblOrders.orderDate, dbo.tblOrders_Products.productName, dbo.tblOrders_Products.productCode, 
                      dbo.tblCustomers_ShippingAddress.Shipping_State, dbo.tblCustomers_ShippingAddress.Shipping_PostCode, dbo.tblCustomers.street, dbo.tblCustomers.street2, 
                      dbo.tblCustomers.suburb, dbo.tblCustomers.state, dbo.tblCustomers.postCode, 
                      dbo.tblCustomers_ShippingAddress.Shipping_FirstName + '  ' + dbo.tblCustomers_ShippingAddress.Shipping_Surname AS ShippingName, 
                      dbo.tblCustomers_ShippingAddress.Shipping_Company, dbo.tblCustomers_ShippingAddress.Shipping_Street, dbo.tblCustomers_ShippingAddress.Shipping_Street2, 
                      dbo.tblCustomers_ShippingAddress.Shipping_Suburb, dbo.tblOrders_Products.productPrice, 
							 dbo.tblOrders_Products.productQuantity, 
							 --dbo.tblCustomers.phone
							CONVERT(VARCHAR(255), dbo.tblOrders_Products.[ID]) as 'phone'
FROM         dbo.tblOrders INNER JOIN
                      dbo.tblCustomers ON dbo.tblOrders.customerID = dbo.tblCustomers.customerID INNER JOIN
                      dbo.tblOrders_Products ON dbo.tblOrders.orderID = dbo.tblOrders_Products.orderID INNER JOIN
                      dbo.tblCustomers_ShippingAddress ON dbo.tblCustomers.customerID = dbo.tblCustomers_ShippingAddress.CustomerID


--SELECT DISTINCT 
--                      TOP (100) PERCENT 
--							 dbo.tblOrders.orderNo, dbo.tblOrders.orderStatus, dbo.tblOrders.orderType, dbo.tblOrders.orderTotal, 
--                      dbo.tblCustomers.firstName + '  ' + dbo.tblCustomers.surname AS customerName, dbo.tblOrders.customerID, 
							 
--							 --dbo.tblCustomers.company, 
--							 '' as 'company',
							 
--							 dbo.tblCustomers.email, 
--                      dbo.tblOrders.displayPaymentStatus, dbo.tblOrders.orderID, dbo.tblOrders.orderDate, dbo.tblOrders_Products.productName, dbo.tblOrders_Products.productCode, 
                      
--							 --dbo.tblCustomers_ShippingAddress.Shipping_State, dbo.tblCustomers_ShippingAddress.Shipping_PostCode, dbo.tblCustomers.street, 
--							 --dbo.tblCustomers.street2, dbo.tblCustomers.suburb, dbo.tblCustomers.state, dbo.tblCustomers.postCode, 
--                      --dbo.tblCustomers_ShippingAddress.Shipping_FirstName + '  ' + dbo.tblCustomers_ShippingAddress.Shipping_Surname AS ShippingName, 
--                      --dbo.tblCustomers_ShippingAddress.Shipping_Company, dbo.tblCustomers_ShippingAddress.Shipping_Street, dbo.tblCustomers_ShippingAddress.Shipping_Street2, 
--							 --dbo.tblCustomers_ShippingAddress.Shipping_Suburb,
--							 '' as 'Shipping_state', CONVERT(VARCHAR(255), dbo.tblOrders_Products.[ID]) as 'Shipping_PostCode', '' as 'street',
--							 '' as 'street2', '' as 'suburb', '' as 'state', '' AS 'postCode',
--							 '' as 'shippingName',
--							 '' as 'Shipping_Company', '' as 'Shipping_Street', '' as 'Shipping_Street2',  '' as 'Shipping_Suburb', 

--							 dbo.tblOrders_Products.productPrice, 
--							 dbo.tblOrders_Products.productQuantity, 
--							 --dbo.tblCustomers.phone
--							'' as 'phone'
--FROM         dbo.tblOrders INNER JOIN
--                      dbo.tblCustomers ON dbo.tblOrders.customerID = dbo.tblCustomers.customerID INNER JOIN
--                      dbo.tblOrders_Products ON dbo.tblOrders.orderID = dbo.tblOrders_Products.orderID INNER JOIN
--                      dbo.tblCustomers_ShippingAddress ON dbo.tblCustomers.customerID = dbo.tblCustomers_ShippingAddress.CustomerID
--WHERE tblOrders.orderNo = 'HOM516207'
ORDER BY dbo.tblOrders.orderDate DESC
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tblOrders"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCustomers"
            Begin Extent = 
               Top = 6
               Left = 278
               Bottom = 114
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblOrders_Products"
            Begin Extent = 
               Top = 6
               Left = 486
               Bottom = 114
               Right = 681
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tblCustomers_ShippingAddress"
            Begin Extent = 
               Top = 6
               Left = 719
               Bottom = 114
               Right = 893
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or =', 'SCHEMA', N'dbo', 'VIEW', N'CustomReportsWithProductView', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N' 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'CustomReportsWithProductView', NULL, NULL
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'CustomReportsWithProductView';

