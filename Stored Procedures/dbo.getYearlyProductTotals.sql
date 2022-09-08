CREATE PROCEDURE [dbo].[getYearlyProductTotals]
  @ProductID AS INT
AS 
BEGIN
    SELECT 'Number Sold' as ' '
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2004) AS '2004'  
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2005) AS '2005'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2006) AS '2006'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2007) AS '2007'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2008) AS '2008'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2009) AS '2009'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2010) AS '2010'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2011) AS '2011'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2012) AS '2012'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2013) AS '2013'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2014) AS '2014'
       ,dbo.fnTotalNumberSoldInYear(@Productid, 2015) AS '2015'
		 ,dbo.fnTotalNumberSoldInYear(@Productid, 2016) AS '2016'
     UNION
     SELECT 'Value Sold' as ' '
       ,dbo.fnTotalValueSoldInYear(@Productid, 2004) AS '2004'  
       ,dbo.fnTotalValueSoldInYear(@Productid, 2005) AS '2005'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2006) AS '2006'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2007) AS '2007'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2008) AS '2008'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2009) AS '2009'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2010) AS '2010'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2011) AS '2011'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2012) AS '2012'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2013) AS '2013'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2014) AS '2014'
       ,dbo.fnTotalValueSoldInYear(@Productid, 2015) AS '2015'
		 ,dbo.fnTotalValueSoldInYear(@Productid, 2016) AS '2016'

END