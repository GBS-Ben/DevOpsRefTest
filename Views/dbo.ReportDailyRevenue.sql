
CREATE VIEW [dbo].[ReportDailyRevenue]
AS
SELECT CONVERT(date, t.orderDate, 101) AS OrderDate, COUNT(DISTINCT t.orderNo) AS Order_Count, LEFT(op.productCode, 2) AS ProductCode, SUM(op.productPrice * op.productQuantity) AS Revenue_Amount
FROM      dbo.tblOrders AS t INNER JOIN
                   dbo.tblOrders_Products AS op ON op.orderID = t.orderID INNER JOIN
                   dbo.DateDimension AS d ON d.DateKey = CONVERT(VARCHAR(8), t.orderDate, 112)
WHERE   (t.orderStatus NOT IN ('Cancelled', 'Failed', 'Waiting for Payment'))
	AND OrderDate> '12/31/2018'
GROUP BY CONVERT(date, t.orderDate, 101), LEFT(op.productCode, 2)
--ORDER BY Year_Month DESC
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
         Begin Table = "t"
            Begin Extent = 
               Top = 8
               Left = 52
               Bottom = 178
               Right = 345
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "op"
            Begin Extent = 
               Top = 8
               Left = 397
               Bottom = 178
               Right = 728
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "d"
            Begin Extent = 
               Top = 8
               Left = 780
               Bottom = 178
               Right = 1045
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 897
         Table = 1174
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1351
         SortOrder = 1407
         GroupBy = 1350
         Filter = 1351
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'ReportDailyRevenue', NULL, NULL
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ReportDailyRevenue';

